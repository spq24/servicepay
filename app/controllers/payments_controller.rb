class PaymentsController < ApplicationController
	before_action :authenticate_user!, except: [:new, :create, :show]
	before_action :set_qb_service, only: [:edit, :update, :create, :destroy]

	def new
		@company = Company.find(params[:id])
		@user = @company.users.first
		@payment = Payment.new
		@customer = @company.customers.last
		@coupon = Coupon.find_by_name_and_company_id(params[:coupon], @company.id)
	end

	def create
		@company = Company.find(params[:payment][:company_id])
		Stripe.api_key = @company.access_code
		@money = Money.new((params[:payment][:amount].to_f * 100).to_i, "USD")	
		@coupon = Coupon.find_by_name(params[:coupon_code])
		@customer = Customer.find_by_customer_name_and_customer_email_and_company_id(params[:payment][:customer_attributes][:customer_name], params[:payment][:customer_attributes][:customer_email], @company.id)
		@customer_by_email = Customer.find_by_customer_email_and_company_id(params[:payment][:customer_attributes][:customer_email], @company.id)
		@payment = Payment.new(amount: params[:payment][:amount], company_id: params[:payment][:company_id])
		@card_brand = Stripe::Token.retrieve(params[:stripeToken])[:card][:brand]
		if @payment.valid?
			if @coupon.present?
				count = @coupon.redeemed_count
				@coupon.redeemed_count = count + 1
				@coupon.save
				money_percent = @money * @coupon.percent_off.to_f / 100
				money_off = @coupon.percent_off.nil? ? Money.new((@coupon.amount_off.to_s.to_f * 100).to_i, "USD") : Money.new((money_percent.to_s.to_f * 100).to_i, "USD")
				amount_to_charge = @money - money_off
			else
				amount_to_charge = @money
			end
			app_fee = @card_brand == "American Express" ? Money.new((0).to_i, "USD"): amount_to_charge  * (@company.application_fee / 100)
			
			if @customer.nil? && @customer_by_email.nil?
				stripe_customer = StripeWrapper::Customer.create(source: params[:stripeToken], customer_email: params[:payment][:customer_attributes][:customer_email], uid: @company.uid)
				if stripe_customer.successful?
				    @customer = Customer.create(customer_email: params[:payment][:customer_attributes][:customer_email], customer_name: params[:payment][:customer_attributes][:customer_name], company_id: @company.id, stripe_token: stripe_customer.response.id, address_one: params[:payment][:customer_attributes][:address_one], address_two: params[:payment][:customer_attributes][:address_two], city: params[:payment][:customer_attributes][:city], postcode: params[:payment][:customer_attributes][:postcode], state: params[:payment][:customer_attributes][:state], phone: params[:payment][:customer_attributes][:phone])	
				    add_cio
				    add_customer_to_quickbooks unless @company.quickbooks_token.nil?
					result = StripeWrapper::Charge.create(customer: @customer.stripe_token, uid: @company.uid, amount: amount_to_charge.cents,  fee: app_fee.cents)
					if result.successful?
						@payment = Payment.create(company_id: @company.id, amount: amount_to_charge.cents, invoice_number: params[:payment][:invoice_number], customer_id: @customer.id, stripe_charge_id: result.response.id, last_4: result.response.source.last4, app_fee: app_fee.cents)
						if @coupon.present?
							@payment.coupon_id = @coupon.id
							@payment.save
						end
						track_cio
						add_payment_to_quickbooks unless @company.quickbooks_token.nil?
					    flash[:success] = @coupon.present? ? "Your Payment of #{ActionController::Base.helpers.number_to_currency(@payment.amount / 100)} Was Successful! #{@coupon.name} was applied to your payment!" : "Your Payment of #{ActionController::Base.helpers.number_to_currency(@payment.amount / 100)} Was Successful!"
					    redirect_to payment_path(@payment)
				    else
				      flash[:danger] = result.error_message
				      render :new
			    	end
				else
					flash[:danger] = result.error_message
					render :new
				end
			else
				@customer = @customer_by_email unless @customer.present?
		        if @customer.quickbooks_customer_id.nil?
		          add_customer_to_quickbooks unless @company.quickbooks_token.nil?
		        end
				if Stripe::Customer.retrieve(@customer.stripe_token)[:default_source] != Stripe::Token.retrieve(params[:stripeToken])[:card][:id]
					stripe_customer = Stripe::Customer.retrieve(@customer.stripe_token)
					stripe_customer.source = params[:stripeToken]
					stripe_customer.save
				end

				result = StripeWrapper::Charge.create(customer: @customer.stripe_token, uid: @company.uid, amount: amount_to_charge.cents,  fee: app_fee.cents)
				if result.successful?
					@payment = Payment.create(company_id: @company.id, amount: amount_to_charge.cents, invoice_number: params[:payment][:invoice_number], customer_id: @customer.id, stripe_charge_id: result.response.id, last_4: result.response.source.last4, app_fee: app_fee.cents)
					if @coupon.present?
						@payment.coupon_id = @coupon.id
						@payment.save
					end
					track_cio
					add_payment_to_quickbooks unless @company.quickbooks_token.nil?
				    flash[:success] = @coupon.present? ? "Your Payment of #{ActionController::Base.helpers.number_to_currency(@payment.amount / 100)} Was Successful! #{@coupon.name} was applied to your payment!" : "Your Payment of #{ActionController::Base.helpers.number_to_currency(@payment.amount / 100)} Was Successful!"
				    redirect_to payment_path(@payment)
			    else
			      flash[:danger] = result.error_message
			      render :new
		    	end
			end
		else
		  flash[:danger] = "There was a problem with your payment. #{@payment.errors.full_messages.to_sentence}"
		  render :new
		end
	end

	def show
		@payment = Payment.find(params[:id])
		@company = @payment.company
		@user = @company.users.first
		@review = Review.new
		@customer = @payment.customer
	end

	def index
	    @user = current_user
	    @company = @user.company
	    @payments = @company.payments.order(id: :desc).page params[:page]
	    @payments_all = @company.payments
	    @refunds = @company.refunds
	    @refunded_amount = Money.new((@refunds.sum(:amount)), "USD")
	    @payments_amount = Money.new((@payments_all.sum(:amount)), "USD")
	    @revenue = @payments_amount - @refunded_amount
	end

  private

	def payment_params
	    params.require(:payment).permit(:company_id, :amount, :refunded, :invoice_number, :subscription, :plan_id, :coupon_id, :customer_id, :stripe_charge_id)
	end

	def add_cio
    	$customerio.identify(
		  id: @customer.id,
		  created_at: @customer.created_at,
		  email: @customer.customer_email,
		  name: @customer.customer_name,
		  company_name: Company.find(@customer.company_id).company_name,
		  company_id: Company.find(@customer.company_id).id,
		  customer: true,
		  reviewed: false
		)
		$customerio.track(@customer.id, "new customer")
	end

	def track_cio
		$customerio.track(@customer.id,"sale", customer_name: @payment.customer.customer_name, invoice_number: @payment.invoice_number, amount: @payment.amount, company_user_email: @company.users.first.email, company_logo: @company.logo, facebook_url: @company.facebook, google_url: @company.google, yelp_url: @company.yelp)
		$customerio.identify(id: @customer.id, reviewed: false, last_payment_id: @payment.id)
	end

	def add_customer_to_quickbooks
		customer = Quickbooks::Model::Customer.new
		binding.pry
		customer_name_in_db = Customer.where(customer_name: @customer.customer_name, company_id: @company.id).to_a
		if customer_name_in_db.count > 0
			customer_count = customer_name_in_db.count + 1
			unique_name = @customer.customer_name + " " + customer_count.to_s
			unique_name = unique_name.length > 24 ? unique_name[0..23] + " " + customer_count.to_s : unique_name
		else
			unique_name = @customer.customer_name[0..24]
		end
		@customer.update_attribute(:unique_name, unique_name)
		customer.given_name = unique_name
		customer.fully_qualified_name = @customer.customer_name
		phone = Quickbooks::Model::TelephoneNumber.new
		phone.free_form_number = @customer.phone
		customer.primary_phone = phone
		customer.email_address = @customer.customer_email
		address = Quickbooks::Model::PhysicalAddress.new
		address.line1 = @customer.address_one
		address.line2 = @customer.address_two
		address.city = @customer.city
		address.country_sub_division_code = @customer.state
		address.postal_code = @customer.postcode
		customer.billing_address = address
		response = @qb_customer.create(customer)
		if response.id.present?
			@customer.update_attribute(:quickbooks_customer_id, response.id)
		end
	end

	def add_payment_to_quickbooks
        amount_to_charge = Money.new(@payment.amount, "USD").format.delete('$')
        invoice = Quickbooks::Model::Invoice.new
        invoice.customer_id = @payment.customer.quickbooks_customer_id
        invoice.txn_date = @payment.created_at
        invoice.doc_number = @payment.invoice_number
        invoice.private_note = @payment.invoice_number + " " + @payment.customer.customer_name
        line_item = Quickbooks::Model::InvoiceLineItem.new
        line_item.amount = amount_to_charge
        line_item.description = "Services Rendered"
        line_item.detail_type = "SalesItemLineDetail"
        line_item.sales_item! do |detail|
          detail.unit_price = amount_to_charge.delete('$')
          detail.quantity = 1
        end

        invoice.line_items << line_item

        created_invoice = @qb_invoice.create(invoice)
    
        if created_invoice.present?
          @payment.update_attribute(:quickbooks_invoice_id, created_invoice.id)
        end           
		payment = Quickbooks::Model::Payment.new
		line = Quickbooks::Model::Line.new
		line.amount = amount_to_charge
        line.linked_transactions << set_linked_transaction(@payment.quickbooks_invoice_id)
        payment.line_items << line
        payment.customer_id = @customer.quickbooks_customer_id
		payment.total = amount_to_charge
        payment.private_note = @payment.invoice_number + " " + @payment.customer.customer_name

        response = @qb_payment.create(payment)

		if response.present?
          @customer.update_attribute(:quickbooks_customer_id, response.customer_ref.value)
		end
	end

	def set_linked_transaction(qbo_id)
	  linked_transaction = Quickbooks::Model::LinkedTransaction.new
	  linked_transaction.txn_id = qbo_id
	  linked_transaction.txn_type = 'Invoice'
	  linked_transaction
	end

 	def set_qb_service
 	  @user = current_user
 	  @company = @user.company
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, @company.quickbooks_token, @company.quickbooks_secret)
      @qb_customer = Quickbooks::Service::Customer.new
      @qb_customer.access_token = oauth_client
      @qb_customer.company_id = @company.quickbooks_realm_id
      @qb_payment = Quickbooks::Service::Payment.new
      @qb_payment.access_token = oauth_client
      @qb_payment.company_id = @company.quickbooks_realm_id
      @qb_invoice = Quickbooks::Service::Invoice.new
      @qb_invoice.access_token = oauth_client
      @qb_invoice.company_id = @company.quickbooks_realm_id
  end
end
class PaymentsController < ApplicationController
	before_action :authenticate_user!, except: [:new, :create, :show]

	def new
		@company = Company.find(params[:id])
		@user = @company.users.first
		@payment = Payment.new
		@customer = @company.customers.last
	end

	def create
		@company = Company.find(params[:payment][:company_id])
		Stripe.api_key = @company.access_code
		@money = Money.new((params[:payment][:amount].to_f * 100).to_i, "USD")	
		@coupon = Coupon.find_by_name(params[:coupon_code])
		@customer = Customer.find_by_customer_email_and_company_id(params[:payment][:customer_attributes][:customer_email], params[:payment][:company_id])
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
		
			if @customer.nil?
				stripe_customer = StripeWrapper::Customer.create(source: params[:stripeToken], customer_email: params[:payment][:customer_attributes][:customer_email], uid: @company.uid)
				if stripe_customer.successful?
				    @customer = Customer.create(customer_email: params[:payment][:customer_attributes][:customer_email], customer_name: params[:payment][:customer_attributes][:customer_name], company_id: @company.id, stripe_token: stripe_customer.response.id)	
				    add_cio
					result = StripeWrapper::Charge.create(customer: @customer.stripe_token, uid: @company.uid, amount: amount_to_charge.cents,  fee: app_fee.cents)
					if result.successful?
						@payment = Payment.create(company_id: @company.id, amount: amount_to_charge.cents, invoice_number: params[:payment][:invoice_number], customer_id: @customer.id, stripe_charge_id: result.response.id, last_4: result.response.source.last4)
						if @coupon.present?
							@payment.coupon_id = @coupon.id
							@payment.save
						end
						track_cio
					    flash[:success] = @coupon.present? ? "Your Payment of #{ActionController::Base.helpers.number_to_currency(@payment.amount)} Was Successful! #{@coupon.name} was applied to your payment!" : "Your Payment of #{ActionController::Base.helpers.number_to_currency(@payment.amount)} Was Successful!"
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
				if Stripe::Customer.retrieve(@customer.stripe_token)[:default_source] != Stripe::Token.retrieve(params[:stripeToken])[:card][:id]
					stripe_customer = Stripe::Customer.retrieve(@customer.stripe_token)
					stripe_customer.source = params[:stripeToken]
					stripe_customer.save
				end

				result = StripeWrapper::Charge.create(customer: @customer.stripe_token, uid: @company.uid, amount: amount_to_charge.cents,  fee: app_fee.cents)
				if result.successful?
					@payment = Payment.create(company_id: @company.id, amount: amount_to_charge, invoice_number: params[:payment][:invoice_number], customer_id: @customer.id, stripe_charge_id: result.response.id, last_4: result.response.source.last4)
					if @coupon.present?
						@payment.coupon_id = @coupon.id
						@payment.save
					end
					track_cio
				    flash[:success] = @coupon.present? ? "Your Payment of #{ActionController::Base.helpers.number_to_currency(@payment.amount)} Was Successful! #{@coupon.name} was applied to your payment!" : "Your Payment of #{ActionController::Base.helpers.number_to_currency(@payment.amount)} Was Successful!"
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
end
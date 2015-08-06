class RefundsController < ApplicationController
  before_action :authenticate_user!, if: :user_signed_in?
  before_action :allowed_user, only: [:edit, :update, :show, :destroy]
  before_action :set_qb_service, only: [:create]

	def new
		@user = current_user
		@company = @user.company
		@payment = Payment.find(params[:payment_id])
		@customer = @payment.customer
		@refund = Refund.new
	end

	def create
		@user = current_user
		@refund_amount = Money.new((params[:refund][:amount].to_f * 100).to_i, "USD")	
		@payment = Payment.find(params[:refund][:payment_id])
		@company = @payment.company
		@customer = @payment.customer
		Stripe.api_key = @company.access_code
		stripe_charge = Stripe::Charge.retrieve(@payment.stripe_charge_id, stripe_account: @company.uid)
		@refund = Refund.new(amount: @refund_amount.cents, payment_id: @payment.id, company_id: @company.id, user_id: @user.id, customer_id: @customer.id, reason: params[:refund][:reason])
		if @refund.valid?
			@result = stripe_charge.refunds.create(amount: @refund_amount.cents)
		    if @result.present?
		      @refund = Refund.create(amount: @refund_amount.cents, payment_id: @payment.id, company_id: @company.id, user_id: @user.id, customer_id: @customer.id, reason: params[:refund][:reason], stripe_refund_id: @result.id)
			    @payment.refunded = true
			    @payment.stripe_refund_id = @result.id
			 		@payment.save
			  	track_cio
		      flash[:success] = "Successfully Refunded #{Money.new((@refund.amount).to_i, "USD").format} to #{@customer.customer_name}. FYI: Refunds are NOT tracked automatically in Quickbooks!"
		      redirect_to company_path(@company)
		    else
		      flash[:danger] = @result.error_message
		      render :new
		    end
		else
			flash[:danger] = "There was a problem with your refund. #{@refund.errors.full_messages.to_sentence}"
			redirect_to refund_payment_path(@payment)
		end
	end

	def show
		@user = current_user
		@company = @user.company
		@refund = Refund.find(params[:id])
		@payment = Payment.find(@refund.payment_id)
	end

	def index
		@user = current_user
		@company = @user.company
		@refunds = @company.refunds.reverse
		@refund_amount = @refunds.map { |r| r.amount }
	end

  private

  def refund_params
    params.require(:refund).permit(:payment_id, :company_id, :stripe_refund_id, :amount, :user_id, :customer_id, :reason)
  end

  def track_cio
		$customerio.track(@refund.customer_id,"refund", customer_name: @refund.customer.customer_name, customer_email: @refund.customer.customer_email, amount: @refund.amount, company_name: @refund.company.company_name, company_user_email: @refund.user.email)
  end


  def allowed_user
		@refund	 = Refund.find(params[:id])	
		@company = @refund.company
		redirect_to root_path unless @company.users.include?(current_user)
		flash[:danger] = "You are not authorized to view that account. Please login as a user associated with that company" unless @company.users.include?(current_user)
  end
  

  def add_refund_to_quickbooks

  	if @customer.quickbooks_customer_id.nil?
  		add_customer_to_quickbooks
  	end

  	amount_of_refund = Money.new(@refund.amount, "USD").format.delete('$')
  	refund = Quickbooks::Model::RefundReceipt.new
  	line = Quickbooks::Model::Line.new
  	line.amount = amount_of_refund
  	refund.line_items << line
  	refund.doc_number = @payment.invoice_number
  	refund.customer_id = @customer.quickbooks_customer_id 
  	refund.private_note = "Refunded #{Money.new(@refund.amount, "USD").format} out of a total payment of #{Money.new(@refund.payment.amount, "USD").format} for Service Pay Payment #{@refund.payment_id}"
  
  	response = @qb_refund.create(refund)

  	if response.present?
  		@refund.update_attribute(:quickbooks_refund_id, response.id)
	end

  end

	def add_customer_to_quickbooks
		customer = Quickbooks::Model::Customer.new
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

  def set_qb_service
    @user = current_user
    @company = @user.company
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, @company.quickbooks_token, @company.quickbooks_secret)
    @qb_refund = Quickbooks::Service::RefundReceipt.new
    @qb_refund.access_token = oauth_client
    @qb_refund.company_id = @company.quickbooks_realm_id
    @qb_customer = Quickbooks::Service::Customer.new
    @qb_customer.access_token = oauth_client
    @qb_customer.company_id = @company.quickbooks_realm_id
  end
end

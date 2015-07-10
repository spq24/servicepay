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
		money = Money.new((params[:payment][:amount].to_f * 100).to_i, "USD")
		fee = @company.application_fee.nil? ? 0.8 : @company.application_fee
		app_fee = money * (fee/100)
		@customer = Customer.find_by_customer_email_and_company_id(params[:payment][:customer_attributes][:customer_email], params[:payment][:company_id])
		@payment = Payment.new(amount: params[:payment][:amount], company_id: params[:payment][:company_id])
		if @payment.valid?
			if @customer.nil?
				stripe_customer = StripeWrapper::Customer.create(source: params[:stripeToken], customer_email: params[:payment][:customer_attributes][:customer_email], uid: @company.uid)
				if stripe_customer.successful?
				   @customer = Customer.create(customer_email: params[:payment][:customer_attributes][:customer_email], customer_name: params[:payment][:customer_attributes][:customer_name], company_id: @company.id, stripe_token: stripe_customer.response.id)	
				   add_cio
				else
					flash[:danger] = result.error_message
					render :new
				end
			end

			if Stripe::Customer.retrieve(@customer.stripe_token)[:default_source] != Stripe::Token.retrieve(params[:stripeToken])[:card][:id]
				stripe_customer = Stripe::Customer.retrieve(@customer.stripe_token)
				stripe_customer.source = params[:stripeToken]
				stripe_customer.save
			end

			result = StripeWrapper::Charge.create(customer: @customer.stripe_token, uid: @company.uid, amount: money.cents,  fee: app_fee.cents)
			if result.successful?
				  @payment = Payment.create(payment_params)
				  @payment.customer = @customer
				  @payment.company = @company
				  @payment.stripe_charge_id = result.response.id
				  @payment.last_4 = result.response.source.last4
				  @payment.save
				  track_cio
			      flash[:success] = "Your Payment Was Successful!"
			      redirect_to payment_path(@payment)
		    else
		      flash[:danger] = result.error_message
		      render :new
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
	    @payments_count = @company.payments.all
	    @refunds_count = @company.refunds.all
	    @refunded_amount = @refunds_count.sum(:amount)
	    @revenue = @company.payments.all.sum(:amount) - @refunded_amount
	end

  private

	def payment_params
	    params.require(:payment).permit(:user_id, :company_id, :reference_id, :amount, :stripeToken, :refunded, :invoice_number, :application_fee, :subscription, :plan_id)
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
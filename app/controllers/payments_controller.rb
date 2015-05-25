class PaymentsController < ApplicationController
	before_action :authenticate_user!, except: [:new]

	def new
		@company = Company.find(params[:id])
		@user = @company.users.first
		@payment = Payment.new
		@customer = @company.customers.last
	end

	def create
		@company = Company.find(params[:payment][:company_id])
		payment = Money.new((params[:payment][:amount].to_f * 100).to_i, "USD")
		customer = Customer.find_by(customer_email: params[:payment][:customer_attributes][:customer_email])
		result = StripeWrapper::Charge.create(source: params[:stripeToken], uid: @company.uid, amount: payment.cents,  fee: params[:payment][:amount].to_i)
	    if result.successful?
		  @payment = Payment.create(payment_params)
		  @payment.stripe_charge_id = result.response.id
		  @payment.save
		  add_cio
		  track_cio
	      flash[:success] = "Your Payment Was Successful!"
	      redirect_to payment_path(@payment)
	    else
	      flash[:danger] = @result.error_message
	      redirect_to payment_form_path(@company)
	    end
	end

	def thank_you
		@payment = Payment.find(params[:id])
		@company = @payment.company
		@user = @company.users.first
		@review = Review.new
		@customer = @company.customers.last
	end

	def show
		@payment = Payment.find(params[:id])
		@company = @payment.company
		@user = @company.users.first
		@review = Review.new
		@customer = @company.customers.last
	end

  private

	def payment_params
	    params.require(:payment).permit(:user_id, :company_id, :reference_id, :amount, :stripeToken, :customer_name, :customer_email, :refunded, customer_attributes: [:customer_email, :customer_name, :company_id])
	end

	def add_cio
    	$customerio.identify(
		  id: @payment.customer_id,
		  created_at: Customer.find(@payment.customer_id).created_at,
		  email: Customer.find(@payment.customer_id).customer_email,
		  name: Customer.find(@payment.customer_id).customer_name,
		  company_name: Company.find(@payment.company_id).company_name,
		  company_id: Company.find(@payment.company_id).id,
		  customer: true
		)
	end

	def track_cio
		binding.pry
		$customerio.track(@payment.customer_id,"sale", amount: @payment.amount, reviewed: false, company_user_email: User.find_by(company_id: @payment.company_id).email)
	end
end
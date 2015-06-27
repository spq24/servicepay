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
		payment = Money.new((params[:payment][:amount].to_f * 100).to_i, "USD")
		@customer = Customer.find_by_customer_email_and_company_id(params[:payment][:customer_attributes][:customer_email], params[:payment][:company_id])
		@payment = Payment.create(payment_params)
		if @payment.valid?
			result = StripeWrapper::Charge.create(source: params[:stripeToken], uid: @company.uid, amount: payment.cents,  fee: params[:payment][:amount].to_i)
		    if result.successful?
			  if @customer.nil?
				@customer = Customer.create(customer_email: params[:payment][:customer_attributes][:customer_email], customer_name: params[:payment][:customer_attributes][:customer_name], company_id: params[:payment][:company_id])
				add_cio
			  end
				  @payment.customer = @customer
				  @payment.stripe_charge_id = result.response.id
				  @payment.save
				  track_cio
			      flash[:success] = "Your Payment Was Successful!"
			      redirect_to payment_path(@payment)
		    else
		      flash[:danger] = result.error_message
		      redirect_to payment_form_path(@company)
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
		@payments = @company.payments
	end

  private

	def payment_params
	    params.require(:payment).permit(:user_id, :company_id, :reference_id, :amount, :stripeToken, :refunded, :invoice_number, customer_attributes: [:customer_email, :customer_name, :company_id])
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
		$customerio.track(@customer.id,"sale", customer_name: @payment.customer.customer_name, invoice_number: @payment.invoice_number, amount: @payment.amount, company_user_email: User.find_by(company_id: @payment.company_id).email)
		$customerio.identify(id: @customer.id, reviewed: false, last_payment_id: @payment.id)
	end
end
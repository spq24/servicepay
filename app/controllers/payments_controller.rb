class PaymentsController < ApplicationController
	before_action :authenticate_user!, except: [:new]

	def new
		@company = Company.find(params[:id])
		@user = @company.users.first
		@payment = Payment.new
	end

	def create
		@result = StripeWrapper::Customer.create(source: params[:stripeToken])
	    if @result.present?
		  @payment = Payment.create(payment_params)
	      flash[:success] = "Thank you for your payment"
	      redirect_to thank_you_path
	    else
	      flash[:danger] = @result.error_message
	      render :new
	    end
	end

	def show
		@user = current_user
		@company = @user.company
	end

	def thank_you
	end
end

  private

  def payment_params
    params.require(:payment).permit(:user_id, :company_id, :reference_id, :stripeToken, :customer_name, :customer_email)
  end
class RefundsController < ApplicationController
  before_action :authenticate_user!, if: :user_signed_in?
  before_filter :allowed_user, only: [:edit, :update, :show, :destroy]

	def new
		@user = current_user
		@company = @user.company
		@payment = Payment.find(params[:payment_id])
		@customer = @payment.customer
		@refund = Refund.new
	end

	def create
		refund_amount = params[:refund][:amount].gsub(/\D/, '').to_i * 100
		payment = Payment.find(params[:refund][:payment_id])
		company = payment.company
		ch = Stripe::Charge.retrieve(payment.stripe_charge_id, stripe_account: company.uid)
		@refund = Refund.create(refund_params)
		if @refund.valid?
			@result = ch.refunds.create(amount: refund_amount)
		    if @result.present?
			  @refund.stripe_refund_id = @result.id
			  @refund.save
			  payment.refunded = true
			  payment.stripe_refund_id = @result.id
			  payment.save
			  track_cio
		      flash[:success] = "Successfully Refunded Payment"
		      redirect_to company_path(company)
		    else
		      flash[:danger] = @result.error_message
		      render :new
		    end
		else
			flash[:danger] = "There was a problem with your refund. Please make sure all required fields are filled out."
			redirect_to refund_payment_path(payment)
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
end

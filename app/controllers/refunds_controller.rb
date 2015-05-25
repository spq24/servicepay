class RefundsController < ApplicationController
  before_action :authenticate_user!, if: :user_signed_in?

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
		@result = ch.refunds.create(amount: refund_amount)
	    if @result.present?
		  @refund = Refund.create(refund_params)
		  @refund.stripe_refund_id = @result.id
		  @refund.save
		  payment.refunded = true
		  payment.stripe_refund_id = @result.id
		  payment.save
	      flash[:success] = "Successfully Refunded Payment"
	      redirect_to company_path(company)
	    else
	      flash[:danger] = @result.error_message
	      redirect_to render :new
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
    params.require(:refund).permit(:payment_id, :company_id, :stripe_refund_id, :amount, :user_id)
  end

end

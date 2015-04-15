class PaymentsController < ApplicationController
	before_action :authenticate_user!, except: [:new]

	def new
		@company = Company.find(params[:id])
		@user = @company.users.first
		@payment = Payment.new
	end

	def show
		@user = current_user
		@company = @user.company
	end
end

  private

  def payment_params
    params.require(:payment).permit(:user_id, :company_id, :reference_id)
  end
class CompanypaymentsController < InheritedResources::Base

  def index
  	@user = current_user
  	@company = @user.company
  	@company_payments = Companypayment.all.page params[:page]
  end

  def destroy
    Companypayment.find(params[:id]).destroy
    flash[:success] = "Company Payment Deleted"
    redirect_to companypayments_path
  end

  private

    def companypayment_params
      params.require(:companypayment).permit(:amount, :company_id, :stripe_charge_id)
    end
end


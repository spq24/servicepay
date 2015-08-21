class CompanyplansController < InheritedResources::Base
  before_action :authenticate_user!, if: :user_signed_in?

	def new
		@user = current_user
		@company = @user.company
		@company_plan = Companyplan.new
	end

  	def create
      binding.pry
		@user = current_user
		@company = @user.company
		@money = Money.new((params[:companyplan][:amount].to_f * 100).to_i, "USD")
		@company_plan = Companyplan.new(amount: @money.cents, name: params[:companyplan][:name], user_id: @user.id, interval: params[:companyplan][:interval], statement_descriptor: params[:companyplan][:statement_descriptor], currency: params[:companyplan][:currency], custom: params[:companyplan][:custom])
		if @company_plan.valid?
			stripe_plan = Stripe::Plan.create(amount: @money.cents, name: params[:companyplan][:name], id: params[:companyplan][:name], interval: params[:companyplan][:interval], statement_descriptor: params[:companyplan][:statement_descriptor], currency: params[:companyplan][:currency])
			if stripe_plan.id.present?
				@company_plan = Companyplan.create(amount: @money.cents, name: params[:companyplan][:name], user_id: @user.id, interval: params[:companyplan][:interval], statement_descriptor: params[:companyplan][:statement_descriptor], currency: params[:companyplan][:currency], custom: params[:companyplan][:custom])
				flash[:success] = "#{@company_plan.name} created"
				redirect_to companyplans_path
			else
				flash[:danger] = "There was a problem creating your plan. #{result.error_message}"
				redirect_to new_companyplan_path
			end
		else
		  flash[:danger] = "There was a problem creating your plan. #{@company_plan.errors.full_messages.to_sentence}"
		  redirect_to new_companyplan_path
		end		
	end

	def index
		@user = current_user
		@company = @user.company
		@company_plans = Companyplan.all.page params[:page]
		@companypayments = Companypayment.all
		@revenue = @companypayments.map { |a| a.amount }.sum
	end

	def show
		@user = current_user
		@company = @user.company
		@company_plan = Companyplan.find(params[:id])
		@company_plan_companies = @company_plan.companies.reverse
		@revenue = Money.new((Companypayment.where(companyplan_id: @company_plan.id, company_id: @company.id).sum(:amount)), "USD").format
		@payments_count = Companypayment.where(companyplan_id: @company_plan.id, company_id: @company.id)
	end
  


	def destroy
	  @user = current_user
	  @company = @user.company
	  @plan = Companyplan.find(params[:id])
	  response = Stripe::Plan.retrieve(@plan.name).delete
	  if response[:deleted] == true
		@plan.destroy
		flash[:success] = "#{@plan.name} Deleted."
		redirect_to companyplans_path
	  else
	  	flash[:danger] = "We couldn't delete your plan right now. Please try again soon"
	  	redirect_to companyplans_path
	  end
	end

	def upgrade
		@user = current_user
		@company = @user.company
		@plans = Companyplan.where.not(custom: true)
	end

  private

    def companyplan_params
      params.require(:companyplan).permit(:name, :amount, :user_id, :statement_descriptor, :currency, :custom, :interval)
    end
end


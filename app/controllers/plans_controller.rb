class PlansController < ApplicationController
  before_action :authenticate_user!, if: :user_signed_in?
  before_action :allowed_user, only: [:edit, :update, :show, :destroy]

	def new
		@user = current_user
		@company = @user.company
		@plan = Plan.new
	end

	def create
		@user = current_user
		@company = @user.company
		@plan = Plan.new(amount: params[:plan][:amount], name: params[:plan][:name], user_id: params[:plan][:user_id], company_id: params[:plan][:company_id], interval: params[:plan][:interval], statement_descriptor: params[:plan][:statement_descriptor], currency: params[:plan][:currency])
		if @plan.valid?
			Stripe.api_key = @company.access_code
			stripe_plan = Stripe::Plan.create(amount: params[:plan][:amount], name: params[:plan][:name], id: params[:plan][:name], interval: params[:plan][:interval], statement_descriptor: params[:plan][:statement_descriptor], currency: params[:plan][:currency])
			if stripe_plan.id.present?
				Plan.create(plan_params)
				track_cio
				flash[:success] = "#{@plan.name} created"
				redirect_to plans_path
			else
				flash[:danger] = "There was a problem creating your plan. #{result.error_message}"
			end
		else
		  flash[:danger] = "There was a problem creating your plan. #{@plan.errors.full_messages.to_sentence}"
		  render :new
		end		
	end

	def show
		@user = current_user
		@company = @user.company
		@plan = Plan.find(params[:id])
		@plan_customers = @plan.customers.reverse
		@company_customers = @company.customers
	end

	def index
		@user = current_user
		@company = @user.company
		@plans = @company.plans.reverse
	end

	def destroy
	  @user = current_user
	  @company = @user.company
	  Stripe.api_key = @company.access_code
	  response = Stripe::Plan.retrieve(@plan.name).delete
	  if response[:deleted] == true
		@plan = Plan.find(params[:id]).destroy
		flash[:success] = "Plan Deleted."
		redirect_to plans_path
	  else
	  	flash[:danger] = "We couldn't delete your plan right now. Please try again soon"
	  	redirect_to plans_path
	  end
	end


    private

    def plan_params
      params.require(:plan).permit(:name, :amount, :company_id, :user_id, :statement_descriptor, :currency, :interval)
    end

	def allowed_user
	  @plan = Plan.find(params[:id])
	  @company = @plan.company
	  redirect_to root_path unless @company.users.include?(current_user)
	  flash[:danger] = "You are not authorized to view that account. Please login as a user associated with that company" unless @company.users.include?(current_user)
	end

	def track_cio
		$customerio.track(@company.id,"plan create", plan: @plan.name, amount: @plan.amount, interval: @plan.interval, company_user_email: @plan.users.first.email, company_logo: @company.logo)
	end


end
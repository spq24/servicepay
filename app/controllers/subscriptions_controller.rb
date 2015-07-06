class SubscriptionsController < ApplicationController

	def new
		@user = current_user
		@company = @user.company
		@plan = Plan.find(params[:plan_id])
		@customers_to_add = @company.customers - @plan.customers
		@subscription = Subscription.new
	end

	def create
		binding.pry
		@plan = Plan.find(params[:subscription][:plan_id])
		if @plan.customers << Customer.where(id: params[:subscription][:customer_id])
			flash[:success] = "Successfully Added Customers to Plan"
			redirect_to plan_path(@plan)
		else
			flash[:danger] = "There was a problem adding your customers to this plan"
			render :new
		end
	end

	def edit
	end

	def update
	end

	def destroy
	end

	private
	  
	def subscription_params
	    params.require(:subscription).permit(:customer_id, :plan_id, :stripe_subscription_id)
	end
end

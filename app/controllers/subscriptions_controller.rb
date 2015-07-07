class SubscriptionsController < ApplicationController
	before_action :authenticate_user!, if: :user_signed_in?
	before_action :allowed_user, only: [:new, :create, :show, :destroy]

	def new
		@user = current_user
		@company = @user.company
		@plan = Plan.find(params[:plan_id])
		@customers_to_add = @company.customers - @plan.customers
		@subscription = Subscription.new
	end

	def create
		@user = current_user
		@company = @user.company
		@plan = Plan.find(params[:subscription][:plan_id])
		Stripe.api_key = @company.access_code
		@customers = Customer.where(id: params[:subscription][:customer_id])
		@customers.each do |c|
			stripe_customer = Stripe::Customer.retrieve(c.stripe_token)
			response = stripe_customer.subscriptions.create(plan: @plan.name)
			if response.id.present?
				@plan.customers << c
				@subscription = Subscription.where(customer_id: c.id, plan_id: @plan.id).first
				@subscription.update_attributes(stripe_subscription_id: response.id)
			else
				break
				flash[:danger] = "There was a problem adding your customers to this plan"
				render :new
			end
		end
		flash[:success] = "Successfully Added Customers to Plan"
		redirect_to plan_path(@plan)
	end

	def destroy
		@subscription = Subscription.find(params[:id])
		stripe_customer = Stripe::Customer.retrieve(Customer.find(@subscription.customer_id).stripe_token)
		response = stripe_customer.subscriptions.retrieve(@subscription.stripe_subscription_id).delete
		if response[:status] == "canceled"
			@subscription.destroy
			flash[:success] = "Subscription to #{@subscription.plan.name} Deleted."
			redirect_to session[:return_to] ||= request.referer
		else
			flash[:danger] = "We couldn't delete your subscription right now. Please try again soon"
			redirect_to customer_path(@subscription.customer)
		end
	end

	private
	  
	def subscription_params
	    params.require(:subscription).permit(:customer_id, :plan_id, :stripe_subscription_id)
	end

	def allowed_user
	  @plan = Plan.find(params[:plan_id])
	  @company = @plan.company
	  redirect_to root_path unless @company.users.include?(current_user)
	  flash[:danger] = "You are not authorized to view that account. Please login as a user associated with that company" unless @company.users.include?(current_user)
	end
end

class CustomersController < ApplicationController
	before_action :authenticate_user!, if: :user_signed_in?
	before_filter :allowed_user, only: [:show, :edit, :update, :destroy]

	def new
		@customer = Customer.new
	end

	def create
	    @customer = Customer.create(customer_params)
	end

	def edit
	    @customer = Customer.find(params[:id])
	    @user = current_user
	end

	def update
	    @user = current_user
	    @customer = Customer.find(params[:id])
	    if @customer.update_attributes(customer_params)
	      flash[:success] = "You have successfully edited This Customer"
	      redirect_to edit_customer_path
	    else
	      @error_message = "Oops something went wrong. Please check the information you entered"
	      self
	    end
	end

	def show
		@user = current_user
		@company = @user.company
		@customer = Customer.find(params[:id])
		@payments = @customer.payments.reverse
		@reviews = @customer.reviews.reverse
		require "stripe"
		Stripe.api_key = @company.access_code
		stripe_customer = Stripe::Customer.retrieve(@customer.stripe_token)
		default_card = stripe_customer[:default_source]
		@default_last_4 = stripe_customer.sources.retrieve(default_card)[:last4]
		@brand = stripe_customer.sources.retrieve(default_card)[:brand]
		@all_cards = stripe_customer.sources.all(:object => "card")
	end

	def index
		@user = current_user
		@company = @user.company
		@customers = @company.customers.reverse
		@payments = @company.payments	
	end

	def destroy
	    @customer = Customer.find(params[:id]).destroy
	    flash[:success] = "Customer Deleted."
	    $customerio.delete(@customer.id)
	    redirect_to customers_path
	end

	private
	  
	def customer_params
	    params.require(:customer).permit(:customer_email, :customer_name, :company_id, :deleted_at)
	end

	def allowed_user
		@binding.pry
		@customer = Customer.find(params[:id])	
    	@company = @customer.company
    	redirect_to root_path unless @company.users.include?(current_user)
    	flash[:danger] = "You are not authorized to view that account. Please login as a user associated with that company" unless @company.users.include?(current_user)
    end
end

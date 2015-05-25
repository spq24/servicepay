class CustomersController < ApplicationController

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
		@payments = @customer.payments
	end

	def index
		@user = current_user
		@company = @user.company
		@customers = @company.customers.reverse
		@payments = @company.payments.all	
	end

	def destroy
	  Customer.find(params[:id]).destroy
	  flash[:success] = "Customer Deleted."
	  redirect_to customers_path
	end

	private
	  
	def customer_params
	    params.require(:customer).permit(:customer_email, :customer_name, :company_id, :deleted_at)
	end
end

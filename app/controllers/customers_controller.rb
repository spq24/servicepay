class CustomersController < ApplicationController
	before_action :authenticate_user!, if: :user_signed_in?
	before_action :set_up_basics
	before_filter :allowed_user, only: [:show, :edit, :update, :destroy]
	before_action :set_qb_service, only: [:index, :edit, :update, :create, :destroy]

	def new
		@customer = Customer.new
	end

	def create
		@customer_by_email = Customer.find_by_customer_email_and_company_id(params[:customer][:customer_email], @company.id)
		@customer = Customer.new(customer_email: params[:customer][:customer_email], customer_name: params[:customer][:customer_name], company_id: @company.id, address_one: params[:customer][:address_one], address_two: params[:customer][:address_two], city: params[:customer][:city], postcode: params[:customer][:postcode], state: params[:customer][:state], phone: params[:customer][:phone])
		if @customer.valid?
			if @customer_by_email.nil?
				stripe_customer = StripeWrapper::Customer.create(source: params[:stripeToken], customer_email: params[:customer][:customer_email], uid: @company.uid)
				if stripe_customer.successful?
					@customer = Customer.create(customer_email: params[:customer][:customer_email], customer_name: params[:customer][:customer_name], company_id: @company.id, stripe_token: stripe_customer.response.id, address_one: params[:customer][:address_one], address_two: params[:customer][:address_two], city: params[:customer][:city], postcode: params[:customer][:postcode], state: params[:customer][:state], phone: params[:customer][:phone])
					add_cio
					add_to_quickbooks unless @company.quickbooks_token.nil?
					flash[:success] = "#{@customer.customer_name.titleize} has been added!"
					redirect_to customers_path
				else
					flash[:danger] = stripe_customer.error_message
					render :new
				end
			else
				flash[:danger] = "Customer's are identified by a unique email. A customer with this email already exists"
				render :new
			end
		else
			flash[:danger] = @customer.errors.full_messages.to_sentence
			render :new
		end
	end

	def edit
	    @customer = Customer.find(params[:id])
	end

	def update
		if URI(request.referer).path == edit_customer_path
		    @customer = Customer.find(params[:id])

		    if @customer.customer_email != params[:customer][:customer_email]
		    	stripe_customer = Stripe::Customer.retrieve(@customer.stripe_token)
		    	stripe_customer.email = params[:customer][:customer_email]
		    	stripe_customer.save
		    end

		    if @customer.company.quickbooks_token.present?
		    	update_qbo_customer
		    end

		    if @customer.update_attributes(customer_params)
		      flash[:success] = "You have successfully edited #{@customer.customer_name.titleize}"
		      redirect_to edit_customer_path
		    else
		      @error_message = "Oops something went wrong. Please check the information you entered"
		      self
		    end
		else
			stripe_customer = Stripe::Customer.retrieve(@customer.stripe_token)
			stripe_customer.sources.create(source: params[:stripeToken])
			redirect_to customer_path(@customer)
		end
	end

	def show
		@customer = Customer.find(params[:id])
		@payments = @customer.payments.order(id: :desc).page params[:page] 
		@reviews = @customer.reviews.order(id: :desc).page params[:page] 
		@subscriptions = Subscription.where(customer_id: @customer.id).order(id: :desc).page params[:page]
		stripe_customer = Stripe::Customer.retrieve(@customer.stripe_token)
		default_card = stripe_customer[:default_source]
		@default_last_4 = stripe_customer.sources.retrieve(default_card)[:last4]
		@brand = stripe_customer.sources.retrieve(default_card)[:brand]
		@all_cards = stripe_customer.sources.all(:object => "card")
		@stripe_invoices = Stripe::Invoice.all(customer: stripe_customer.id)
		@contacts = @customer.contacts
	end

	def index
		@customers = @company.customers.reverse
		@payments = @company.payments
	end

	def destroy
	    @customer = Customer.find(params[:id])

	    if @company.quickbooks_token.present?
	    	customer = Quickbooks::Model::Customer.new
			customer.id = @customer.quickbooks_customer_id
			customer.active = false
			@qb_customer.update(customer, :sparse => true)
	   	end
	    
	    response = Stripe::Customer.retrieve(@customer.stripe_token).delete
	    if response[:deleted] == true
		    @customer.destroy
		    flash[:success] = "#{@customer.customer_name.titleize} Deleted."
		    $customerio.delete(@customer.id)
		    redirect_to customers_path
	    else
	  	    flash[:danger] = "We couldn't delete #{@customer.customer_name} right now. Please try again soon"
	  	    redirect_to customers_path
	  end
	end



	private
	  
		def customer_params
		    params.require(:customer).permit(:customer_email, :customer_name, :company_id, :address_one, :address_two, :city, :country, :postcode, :state, :phone, :deleted_at, :quickbooks_customer_id, :unique_name , subscription_attributes: [:stripe_subscription_id])
		end

		def allowed_user
			@customer = Customer.find(params[:id])	
	    	@company = @customer.company
	    	redirect_to root_path unless @company.users.include?(current_user)
	    	flash[:danger] = "You are not authorized to view that account. Please login as a user associated with that company" unless @company.users.include?(current_user)
	    end

		def add_cio
	    	$customerio.identify(
			  id: @customer.id,
			  created_at: @customer.created_at,
			  email: @customer.customer_email,
			  name: @customer.customer_name,
			  company_name: Company.find(@customer.company_id).company_name,
			  company_id: Company.find(@customer.company_id).id,
			  customer: true,
			  reviewed: false
			)
			$customerio.track(@customer.id, "new customer")
		end

		def add_to_quickbooks
			customer = Quickbooks::Model::Customer.new
			customer_name_in_db = Customer.where(customer_name: @customer.customer_name, company_id: @company.id).to_a
			if customer_name_in_db.count > 0
				customer_count = customer_name_in_db.count + 1
				unique_name = @customer.customer_name + " " + customer_count.to_s
				unique_name = unique_name.length > 24 ? unique_name[0..23] + " " + customer_count.to_s : unique_name
			else
				unique_name = @customer.customer_name[0..24]
			end
			@customer.update_attribute(:unique_name, unique_name)
			customer.given_name = unique_name
			customer.fully_qualified_name = @customer.customer_name
			phone = Quickbooks::Model::TelephoneNumber.new
			phone.free_form_number = @customer.phone
			customer.primary_phone = phone
			customer.email_address = @customer.customer_email
			address = Quickbooks::Model::PhysicalAddress.new
			address.line1 = @customer.address_one
			address.line2 = @customer.address_two
			address.city = @customer.city
			address.country_sub_division_code = @customer.state
			address.postal_code = @customer.postcode
			customer.billing_address = address
			response = @qb_customer.create(customer)
			if response.id.present?
				@customer.update_attribute(:quickbooks_customer_id, response.id)
			end
		end

		def update_qbo_customer
			customer = @qb_customer.fetch_by_id(@customer.quickbooks_customer_id.to_s)
			if @customer.customer_name != params[:customer][:customer_name]
				customer_name_in_db = Customer.where(customer_name: @customer.customer_name, company_id: @company.id).to_a
				if customer_name_in_db.count > 0
					customer_count = customer_name_in_db.count + 1
					unique_name = @customer.customer_name + " " + customer_count.to_s
					unique_name = unique_name.length > 24 ? unique_name[0..23] + " " + customer_count.to_s : unique_name
				else
					unique_name = @customer.customer_name[0..24]
				end
				@customer.update_attribute(:unique_name, unique_name)
				customer.given_name = unique_name
				customer.fully_qualified_name = @customer.customer_name
			end
			phone = Quickbooks::Model::TelephoneNumber.new
			phone.free_form_number = @customer.phone
			customer.primary_phone = phone
			customer.email_address = @customer.customer_email
			address = Quickbooks::Model::PhysicalAddress.new
			address.line1 = @customer.address_one
			address.line2 = @customer.address_two
			address.city = @customer.city
			address.country_sub_division_code = @customer.state
			address.postal_code = @customer.postcode
			customer.billing_address = address
			@qb_customer.update(customer)
		end

	 	def set_qb_service
	      	oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, @company.quickbooks_token, @company.quickbooks_secret)
	      	@qb_customer = Quickbooks::Service::Customer.new
	      	@qb_customer.access_token = oauth_client
	      	@qb_customer.company_id = @company.quickbooks_realm_id
	    end

	    def set_up_basics
			@user = current_user
			@company = @user.company
			Stripe.api_key = @company.access_code
	    end
end

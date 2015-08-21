class InvoicesController < ApplicationController
	before_action :authenticate_user!, except: [:customer_show]
	before_filter :allowed_user, only: [:show, :edit, :update, :destroy]
	before_action :set_qb_service, only: [:index, :edit, :update, :create, :destroy]

	def new
		user = current_user
		company = user.company
		invoices = company.invoices
		invoice = Invoice.create! customer_id: params[:customer_id], company_id: company.id, invoice_number: invoices.last.invoice_number.to_i + 1, user_id: user.id
		redirect_to edit_invoice_path(invoice)
	end

	def show
		@invoice = Invoice.find(params[:id])
		@customer = @invoice.customer
		@user = current_user
		@company = @user.company
		respond_to do |format|
	      format.html
	      format.pdf do
	        pdf = InvoicePdf.new(@invoice, @company, @user, @customer, view_context)
	        send_data pdf.render, filename: "invoice_#{@invoice.created_at.strftime("%d/%m/%Y")}.pdf", type: "application/pdf"
	      end
	    end
	end

	def index
		@user = current_user
		@company = @user.company
		@invoices = @company.invoices
	end

	def edit
		@invoice = Invoice.find(params[:id])
		@customer = @invoice.customer
		@user = current_user
		@company = @user.company
		@items = @company.items
		@invoice.invoice_items.build
		@contacts = @customer.contacts
	end

	def update
		@invoice = Invoice.find(params[:id])
		@user = current_user
		@company = @user.company
		@customer = @invoice.customer
		issue_date = Date.strptime(params[:invoice][:issue_date], "%m/%d/%Y")
		amount_of_invoice = Money.new(params[:invoice][:total].gsub(/\D/, ''), "USD").cents
		contacts = params[:customer][:contact_ids].map { |c| c.empty? ? nil : Contact.find(c.to_i).email }.compact
		payment_url = "#{root_url}/companies/#{@company.id}/payment?invoice_number=#{@invoice.invoice_number}&amount=#{@invoice.total}&email=#{@customer.customer_email}&name=#{@customer.customer_name.titleize}&address_one=#{@customer.address_one}&address_two=#{@customer.address_two}&city=#{@customer.city.titleize}&state=#{@customer.state}&post=#{@customer.postcode}&phone=#{@customer.phone}"
	    pdf_url = "#{root_url}invoices/#{@invoice.id}/customer-invoice.pdf"
		if @invoice.update_attributes(total: amount_of_invoice, invoice_number: params[:invoice][:invoice_number], issue_date: issue_date, private_notes: params[:invoice][:private_notes], customer_notes: params[:invoice][:customer_notes], payment_terms: params[:invoice][:payment_terms], draft: params[:invoice][:draft], status: "sent", discount: params[:invoice][:discount], po_number: params[:invoice][:po_number], send_by_email: params[:invoice][:send_by_email], send_by_post: params[:invoice][:send_by_post], recurring: params[:invoice][:recurring])
			
			$customerio.track(@customer.id,"invoice updated", customer_name: @customer.customer_name.titleize, invoice_number: @invoice.invoice_number, invoice_total: @invoice.total, company_name: @company.company_name.titleize, company_user_email: @user.email, company_logo: @company.logo, facebook_url: @company.facebook, google_url: @company.google, yelp_url: @company.yelp, contacts_emails: contacts, payment_url: payment_url, status: @invoice.status.titleize, pdf_url: pdf_url)
		    
		    if @invoice.send_by_post = true
		      send_letter
		    end
	      	
	      	flash[:success] = "Successfully updated invoice #{@invoice.invoice_number} for #{@invoice.customer.customer_name.titleize}"
			
			redirect_to invoice_path(@invoice)
		
		else
			flash[:danger] = "There was a problem creating your invoice. #{@invoice.errors.full_messages.to_sentence}"
      		redirect_to edit_invoice_path(@invoice)
		end
	end

	def destroy
	    @invoice = Invoice.find(params[:id])
	    if @invoice.destroy
	      flash[:success] = "Invoice #{@invoice.invoice_number} successfully deleted."
	      redirect_to invoices_path
	    else
	      flash[:danger] = "Something went wrong. We can't delete invoice number #{@invoice.invoice_number}"
	      redirect_to invoices_path
	    end
	end

	def customer_show
		@invoice = Invoice.find(params[:id])
		@customer = @invoice.customer
		@user = @invoice.user
		@company = @invoice.company
		payments = @company.payments
		@payments_total = payments.where(invoice_id: @invoice.id).map { |t| t.amount }.sum
		@left_to_pay = (@invoice.total - @payments_total) / 100
		respond_to do |format|
	      format.html
	      format.pdf do
	        pdf = InvoicePdf.new(@invoice, @company, @user, @customer, @left_to_pay, view_context)
	        send_data pdf.render, filename: "invoice_#{@invoice.created_at.strftime("%d/%m/%Y")}.pdf", type: "application/pdf"
	      end
	    end
	end

	private

	def invoice_params
		params.require(:invoice).permit(:customer_id, :user_id, :company_id, :invoice_number, :issue_date, :private_notes, :customer_notes, :payment_terms, :draft, :status, :discount, :po_number, :recurring, :interval, :recurring_send_date, :auto_paid, :contact_type, :total, :send_by_email, :send_by_post, invoices_items: [:quanity, :unit_cost, :description, :price])
	end

	def allowed_user
		@invoice = Invoice.find(params[:id])	
    	@company = @invoice.company
    	redirect_to root_path unless @company.users.include?(current_user)
    	flash[:danger] = "You are not authorized to view that account. Please login as a user associated with that company" unless @company.users.include?(current_user)
    end

 	def set_qb_service
		@user = current_user
		@company = @user.company
		oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, @company.quickbooks_token, @company.quickbooks_secret)
		@qb_customer = Quickbooks::Service::Customer.new
		@qb_customer.access_token = oauth_client
		@qb_customer.company_id = @company.quickbooks_realm_id
		@qb_payment = Quickbooks::Service::Payment.new
		@qb_payment.access_token = oauth_client
		@qb_payment.company_id = @company.quickbooks_realm_id
		@qb_invoice = Quickbooks::Service::Invoice.new
		@qb_invoice.access_token = oauth_client
		@qb_invoice.company_id = @company.quickbooks_realm_id
	end

  def send_letter

     pdf_url = "#{root_url}invoices/#{@invoice.id}/customer-invoice.pdf"
     response = $lob.letters.create(
       description: "Invoice for #{@company.company_name.titleize.to_s} sent on #{@invoice.created_at.strftime("%m/%d/%Y")}",
          to: {
            name: @customer.customer_name.to_s,
            address_line1: @customer.address_one.to_s,
            address_city: @customer.city.titleize.to_s,
            address_state: @customer.state.to_s,
            address_country: "US",
            address_zip: @customer.postcode.to_s
          },
          from: {
            name: @company.company_name.titleize.to_s,
            address_line1: @company.address_one.to_s,
            address_city: @company.city.titleize.to_s,
            address_state: @company.state.to_s,
            address_country: "US".to_s,
            address_zip: @company.postcode.to_s
          },
          file: pdf_url,
          color: true
        )
      if response.present?
        @invoice.update_attribute(:lob_letter_id, response.id)
        @invoice.update_attribute(:lob_expected_delivery_date, response.expected_delivery_date)
        @invoice.update_attribute(:lob_to_address_id, response.to.id)
      end
  end

end
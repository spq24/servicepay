class InvoicesController < ApplicationController
	before_action :authenticate_user!
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
		binding.pry
		@invoice = Invoice.find(params[:id])
		@user = current_user
		@company = @user.company
		issue_date = Date.strptime(params[:invoice][:issue_date], "%m/%d/%Y")
		amount_of_invoice = Money.new(params[:invoice][:total].gsub(/\D/, ''), "USD").cents
		if @invoice.update_attributes(total: amount_of_invoice, invoice_number: params[:invoice][:invoice_number], issue_date: issue_date, private_notes: params[:invoice][:private_notes], customer_notes: params[:invoice][:customer_notes], payment_terms: params[:invoice][:payment_terms], draft: params[:invoice][:draft], status: "sent", discount: params[:invoice][:discount], po_number: params[:invoice][:po_number], send_by_email: params[:invoice][:send_by_email], send_by_post: params[:invoice][:send_by_post], recurring: params[:invoice][:recurring])
			flash[:success] = "Successfully created invoice for #{@invoice.customer.customer_name.titleize}"
			redirect_to invoice_path(@invoice)
		else
			flash[:danger] = "There was a problem creating your invoice. #{@invoice.errors.full_messages.to_sentence}"
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

end
class InvoicesController < ApplicationController
  
  
	before_action :authenticate_user!, except: [:customer_show]
	before_filter :allowed_user, only: [:show, :edit, :update, :destroy]
	before_action :set_qb_service, only: [:index, :edit, :update, :create, :destroy]

	skip_before_action :verify_authenticity_token, only: [:update]

	def new
		user = current_user
		company = user.company
		invoices = company.invoices
		invoice_number = invoices.last == nil ? 1 : invoices.last.invoice_number.to_i + 1
		invoice = Invoice.create! customer_id: params[:customer_id], company_id: company.id, invoice_number: invoice_number, user_id: user.id
		redirect_to edit_invoice_path(invoice)
	end

	def show
		@invoice = Invoice.find(params[:id])
		@customer = @invoice.customer
		@user = current_user
		@company = @user.company
		payments = @company.payments
		@payments_total = payments.where(invoice_id: @invoice.id).map { |t| t.amount }.sum
		@left_to_pay = (@invoice.total - @payments_total) / 100
    @invoice_items = InvoiceItem.where(invoice_id: @invoice.id)
		respond_to do |format|
	      format.html
	      format.pdf do
          pdf = InvoicePdf.new(@invoice, @company, @user, @customer, @left_to_pay, @invoice_items, view_context)
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
		@contacts = @customer.contacts
    @amount_paid = Payment.find_by_invoice_id(@invoice.id).present? ? Payment.find_by_invoice_id(@invoice.id).map { |p| p.amount } : nil
	end

	def update
    invoice = Invoice.find(params[:id])
    company = current_user.company
    customer = invoice.customer
    contacts = params[:customer].present? ? params[:customer][:contact_ids].map { |c| c.empty? ? nil : Contact.find(c.to_i).email }.compact : Array.new
    contacts << customer.customer_email
    payment_url = "#{root_url}companies/#{company.id}/payment?invoice_number=#{invoice.invoice_number}&amount=#{invoice.total}&email=#{customer.customer_email}&name=#{customer.customer_name.titleize}&address_one=#{customer.address_one}&address_two=#{customer.address_two}&city=#{customer.city.titleize}&state=#{customer.state}&post=#{customer.postcode}&phone=#{customer.phone}"
    pdf_url = "#{root_url}invoices/#{invoice.id}/customer-invoice.pdf"
    binding.pry
    params[:invoice][:total] = params[:invoice][:total].to_i
    params[:invoice][:status] = "sent"
    params[:invoice][:issue_date] = Date.strptime(params[:invoice][:issue_date], "%m/%d/%Y")
    if invoice.update(invoice_params)
      
      $customerio.track(customer.id,"invoice updated", customer_name: customer.customer_name.titleize, invoice_number: invoice.invoice_number, invoice_total: invoice.total, company_name: company.company_name.titleize, company_user_email: current_user.email, company_logo: company.logo, facebook_url: company.facebook, google_url: company.google, yelp_url: company.yelp, contacts_emails: contacts, payment_url: payment_url, status: invoice.status.titleize, pdf_url: pdf_url)
        
      if invoice.send_by_post == true
        send_letter
      end

        if invoice.send_by_text == true
          invoice_url = "#{root_url}/invoices/#{invoice.id}/customer-invoice"
          to_number = customer.phone.gsub(/\s+/, "").gsub(/[^0-9A-Za-z]/, '')
          client = Twilio::REST::Client.new ENV["twilio_account_sid"], ENV["twilio_auth"]
          message = client.messages.create(from: '+12158834983', to: '+1' + to_number, body: "Thank you for using Service Pay #{customer.customer_name.titleize}. A Link to your invoice from #{company.company_name} is below: #{invoice_url}")
        end
      
      if invoice.recurring == true
        next_send_date = invoice.invoice_interval_number.send(invoice.interval).from_now
        Recurringinvoice.create(customer_id: customer.id, company_id: company.id, invoice_number: invoice.invoice_number, private_notes: invoice.private_notes, customer_notes: invoice.customer_notes, payment_terms: invoice.payment_terms, status: "unpaid", discount: invoice.discount, po_number: invoice.po_number, interval: invoice.interval, invoice_interval_number: invoice.invoice_interval_number, send_by_post: invoice.send_by_post, send_by_text: invoice.send_by_text, send_by_email: invoice.send_by_email, total: invoice.total, number_of_invoices: invoice.number_of_invoices, next_send_date: next_send_date)
      end
      
          flash[:success] = "Successfully updated invoice #{invoice.invoice_number} for #{invoice.customer.customer_name} #{invoice.send_by_post? ? 'It has been sent in the mail with an expected delivery date of' + invoice.lob_expected_delivery_date.to_date.strftime('%m/%d/%Y') : nil}"
      
      redirect_to invoice_path(invoice)
    
    else
      flash[:danger] = "There was a problem creating your invoice. #{invoice.errors.full_messages.to_sentence}"
          redirect_to edit_invoice_path(invoice)
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
    @invoice_items = InvoiceItem.where(invoice_id: @invoice.id)
		respond_to do |format|
	      format.html
	      format.pdf do
          pdf = InvoicePdf.new(@invoice, @company, @user, @customer, @left_to_pay, @invoice_items, view_context)
	        send_data pdf.render, filename: "invoice_#{@invoice.created_at.strftime("%d/%m/%Y")}.pdf", type: "application/pdf"
	      end
	    end
	end

	private

	def invoice_params
		params.require(:invoice).permit(:customer_id, :user_id, :company_id, :invoice_number, :issue_date, :private_notes, :customer_notes, :payment_terms, :draft, :status, :discount, :po_number, :recurring, :interval, :recurring_send_date, :auto_paid, :contact_type, :total, :send_by_email, :send_by_post, :send_by_text, :pdf, :number_of_invoices, :invoice_interval_number, invoice_items_attributes: [:id, :quantity, :unit_cost, :description, :price, :total, :name, :_destroy])
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
          response = $lob.letters.create(
            description: "Invoice for #{@invoice.company.company_name.titleize.to_s} sent on #{@invoice.created_at.strftime("%m/%d/%Y")}",
                to: {
                  name: @invoice.customer.customer_name.to_s,
                  address_line1: @invoice.customer.address_one.to_s,
                  address_city: @invoice.customer.city.titleize.to_s,
                  address_state: @invoice.customer.state.to_s,
                  address_country: "US",
                  address_zip: @invoice.customer.postcode.to_s
                },
                from: {
                  name: @invoice.company.company_name.titleize.to_s,
                  address_line1: @invoice.company.address_one.to_s,
                  address_city: @invoice.company.city.titleize.to_s,
                  address_state: @invoice.company.state.to_s,
                  address_country: "US".to_s,
                  address_zip: @invoice.company.postcode.to_s
                },
                file: "<!DOCTYPE html><html><head> <title>Service Pay</title></head><body class='theme-blue-gradient fixed-header fixed-leftmenu'><div id='login-full-wrapper'> <div class='con tainer'> <div class='row'> <div class='col-xs-12'> <div class='col-lg-12'> <div class='main-box thanks-form'> </div></div><div id='signup-box'> <div class='row'> <div class='col-xs-12'> <header id='signup-header'> <div id='login-logo'> <h4 style='color:#fff;'>Thank you For Your Business From <br>#{@invoice.company.company_name}</h4> </div></header> <style>/* reset */.invoice{border: 0;box-sizing: content-box;color: inherit;font-family: inherit;font-size: inherit;font-style: inherit;font-weight: inherit;line-height: inherit;list-style: none;margin: 0;padding: 0;text-decoration: none;vertical-align: top;}/* content editable */*[contenteditable]{border-radius: 0.25em; min-width: 1em; outline: 0;}*[contenteditable]{cursor: pointer;}*[contenteditable]:hover, *[contenteditable]:focus, td:hover *[contenteditable], td:focus *[contenteditable], img.hover{background: #DEF; box-shadow: 0 0 1em 0.5em #DEF;}span[contenteditable]{display: inline-block;}.bg-white{background-color: #fff;}.invoice-inside{padding: 40px;}.submit{margin-top: 30px;}/* table */.invoice table{font-size: 75%; table-layout: fixed; width: 100%;}.invoice table{border-collapse: separate; border-spacing: 2px;}.invoice th, td{border-width: 1px; padding: 0.5em; position: relative; text-align: left;}.invoice th, td{border-radius: 0.25em; border-style: solid;}.invoice th{background: #EEE; border-color: #BBB;}.invoice td{border-color: #DDD;}/* header */.invoice header{margin: 0 0 3em;}.invoice header:after{clear: both; content: '; display: table;}.invoice header h1{background: #000; border-radius: 0.25em; color: #FFF; margin: 0 0 1em; padding: 0.5em 0;}.invoice header address{float: left; font-size: 1em; font-style: normal; line-height: 1.25; margin: 0 1em 1em 0;}.invoice header address p{margin: 0 0 0.25em;}.invoice header span, header img{display: block; float: right;}.invoice header span{margin: 0 0 1em 1em; max-height: 25%; max-width: 60%; position: relative;}.invoice header img{max-height: 100%; max-width: 100%;}.invoice header input{cursor: pointer; -ms-filter:'progid:DXImageTransform.Microsoft.Alpha(Opacity=0)'; height: 100%; left: 0; opacity: 0; position: absolute; top: 0; width: 100%;}/* article */.invoice article, article address, table.meta, table.inventory{margin: 0 0 3em;}.invoice article:after{clear: both; content: '; display: table;}.invoice article h1{clip: rect(0 0 0 0); position: absolute;}.invoice article address{float: left; font-size: 125%; font-weight: bold;}/* table meta & balance */.invoice table.meta, table.balance{float: right; width: 36%;}.invoice table.meta:after, table.balance:after{clear: both; content: '; display: table;}/* table meta */.invoice table.meta th{width: 40%;}.invoice table.meta td{width: 60%;}/* table items */.invoice table.inventory{clear: both; width: 100%;}.invoice table.inventory th{font-weight: bold; text-align: center;}.invoice table.inventory td:nth-child(1){width: 26%;}.invoice table.inventory td:nth-child(2){width: 38%;}.invoice table.inventory td:nth-child(3){text-align: right; width: 12%;}.invoice table.inventory td:nth-child(4){text-align: right; width: 12%;}.invoice table.inventory td:nth-child(5){text-align: right; width: 12%;}/* table balance */.invoice table.balance th, table.balance td{width: 50%;}.invoice table.balance td{text-align: right;}/* aside */.invoice aside h1{border: none; border-width: 0 0 1px; margin: 0 0 1em;}.invoice aside h1{border-color: #999; border-bottom-style: solid;}/* javascript */.add, .cut{border-width: 1px;display: block;font-size: .8rem;padding: 0.25em 0.5em;float: left;text-align: center;}.add, .cut{background: #9AF;box-shadow: 0 1px 2px rgba(0,0,0,0.2);background-image: -moz-linear-gradient(#00ADEE 5%, #0078A5 100%);background-image: -webkit-linear-gradient(#00ADEE 5%, #0078A5 100%);border-radius: 0.5em;border-color: #0076A3;color: #FFF;cursor: pointer;font-weight: bold;text-shadow: 0 -1px 2px rgba(0,0,0,0.333);}.add{margin: -2.5em 0 0;}.add:hover{background: #00ADEE;}.cut{opacity: 0; position: absolute; top: 0; left: -1.5em;}.cut{-webkit-transition: opacity 100ms ease-in;}tr:hover .cut{opacity: 1;}@media print{*{-webkit-print-color-adjust: exact;}html{background: none; padding: 0;}body{box-shadow: none; margin: 0;}span:empty{display: none;}.add, .cut{display: none;}}@page{margin: 0;}</style><div class='col-xs-12 bg-white invoice-inside'><center><h1>Status: #{@invoice.status}</h1></center><header class='col-xs-8'><h1>Invoice # #{@invoice.invoice_number}</h1><address><h4>Customer Info:</h4><p>#{@invoice.customer.customer_name.titleize}</p><p>#{@invoice.customer.address_one}<br>#{@invoice.customer.city.titleize}, #{@invoice.customer.state.upcase}#{@invoice.customer.postcode}</p><p>#{@invoice.customer.phone}</p></address></header><div class='col-xs-4'><span><img alt='Aws4 request&amp;x amz signedheaders=host&amp;x amz signature=cfe6c4d7681cb8a44ede34f7ee8476eab9c1c7df24fc182f655c1a690e3e4dd3' height='200' src='https://servicepay.s3-us-west-1.amazonaws.com/uploads/company/logo/27/2012-01-04_21.10.53.jpg?X-Amz-Expires=600&amp;X-Amz-Date=20151016T004928Z&amp;X-Amz-Algorithm=AWS4-HMAC-SHA256&amp;X-Amz-Credential=AKIAIPKQXANRX63RP36A/20151016/us-west-1/s3/aws4_request&amp;X-Amz-SignedHeaders=host&amp;X-Amz-Signature=cfe6c4d7681cb8a44ede34f7ee8476eab9c1c7df24fc182f655c1a690e3e4dd3' width='200'></span></div><article class='col-xs-12'><div class='col-xs-8'></div><div class='col-xs-4'><table class='meta'><tr><th class='invoice_th'><span>Invoice #</span></th><td class='invoice_td'><span>#{@invoice.invoice_number}</span></td></tr><tr><th class='invoice_th'><span>PO/Work Order #</span></th><td class='invoice_td'><span>#{@invoice.po_number}</span></td></tr><tr><th class='invoice_th'><span>Invoice Date</span></th><td class='invoice_td'><span>#{@invoice.issue_date.strftime('%m/%d/%Y')}</span></td></tr><tr><th class='invoice_th'><span>Amount Due</span></th><td class='invoice_td'>#{@invoice.total}</td></tr></table></div><table class='inventory col-xs-12'><thead><tr><th class='invoice_th'><span>Item</span></th><th class='invoice_th'><span>Description</span></th><th class='invoice_th'><span>Unit Cost</span></th><th class='invoice_th'><span>Quantity</span></th><th class='invoice_th'><span>Price</span></th></tr></thead><tbody><tr><td class='invoice_td'><span></span></td><td class='invoice_td'><span></span></td><td class='invoice_td'><span data-prefix>$</span><span>0.00</span></td><td class='invoice_td'><span>0</span></td><td class='invoice_td'><span data-prefix>$</span><span>0.00</span></td></tr></tbody></table><table class='balance'><tr><th class='invoice_th'><span>Total</span></th><td class='invoice_td'>#{@invoice.total}</td></tr></table></article><div class='col-sm-12'><div class='col-sm-6'><aside><h1><span>Notes For You</span></h1><div>#{@invoice.customer_notes}</div></aside></div><div class='col-sm-6'><aside><h1><span>Payment Terms</span></h1><div>#{@invoice.payment_terms}</div></aside></div></div></div></div></div></div></div></div></div></div></body></html>",
                color: true
              )
            if response.present?
              @invoice.update_attribute(:lob_letter_id, response["id"])
              @invoice.update_attribute(:lob_expected_delivery_date, response["expected_delivery_date"])
              @invoice.update_attribute(:lob_to_address_id, response["to"]["id"])
            end
  end

end
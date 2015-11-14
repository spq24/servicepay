class RecurringinvoicesController < InheritedResources::Base
	before_action :authenticate_user!, except: [:customer_show]
	before_filter :allowed_user, only: [:show, :edit, :update, :destroy]
  before_action :set_qb_service, only: [:new, :edit, :update, :create, :destroy]
  
  def new
   @user = current_user
   @company = @user.company
   @recurringinvoice = Recurringinvoice.new
   @customers = @company.customers
   @items = @company.items
  end
  
  def create
    binding.pry
    @user = current_user
    @company = @user.company
    next_send_date = params[:recurringinvoice][:invoice_interval_number].to_i.send(params[:recurringinvoice][:interval]).since(Date.strptime(params[:recurringinvoice][:original_issue_date], "%m/%d/%Y"))
    original_issue_date = Date.strptime(params[:recurringinvoice][:original_issue_date], "%m/%d/%Y")
    params[:recurringinvoice][:company_id] = @company.id
    params[:recurringinvoice][:number_sent] = 1
    params[:recurringinvoice][:next_send_date] = next_send_date
    params[:recurringinvoice][:original_issue_date] = original_issue_date
    params[:recurringinvoice][:user_id] = @user.id
    @recurringinvoice = Recurringinvoice.new(recurringinvoice_params)
    if @recurringinvoice.save
      if @recurringinvoice.original_issue_date == Date.today
        create_new_recurring_invoice(@company, @recurringinvoice, root_url)
        @recurringinvoice.update_attributes(original_invoice_id: @invoice.id, last_invoice_id: @invoice.id)
      end
      flash[:success] = "Recurring Invoice has Been Created For " + @recurringinvoice.customer.customer_name.titleize.to_s
      redirect_to recurringinvoice_path(@recurringinvoice)
    else
      flash[:danger] = @recurringinvoice.errors.full_messages.to_sentence
      render :new
    end
  end
  
  
  def index
    @user = current_user
    @company = @user.company
    @recurringinvoices = @company.recurringinvoices.reverse
  end
  
  def show
    @user = current_user
    @company = @user.company
    @recurringinvoice = Recurringinvoice.find(params[:id])
    @customer = @recurringinvoice.customer
    @recurringinvoice_items = RecurringinvoiceItem.where(recurringinvoice_id: @recurringinvoice.id)
    @discontinued_user_name = @recurringinvoice.discontinued? ? "#{User.find(@recurringinvoice.discontinued_user_id).first_name} #{User.find(@recurringinvoice.discontinued_user_id).last_name}" : nil
    @discontinued_date = @recurringinvoice.discontinued_date
    @last_invoice = @recurringinvoice.last_invoice_id.present? ? Invoice.find(@recurringinvoice.last_invoice_id) : nil
    @total_invoiced = Invoice.where(recurringinvoice_id: @recurringinvoice.id).map { |i| i.total }.sum
    @total_collected = Invoice.where(recurringinvoice_id: @recurringinvoice.id, fully_paid: true).map { |i| i.total }.sum
  end
  
  def edit
    if @recurringinvoice.discontinued?
      flash[:danger] = "This invoice has been discontinued. It cannot be edited"
      redirect_to recurringinvoice_path(@recurringinvoice)
    else
      @recurringinvoice = Recurringinvoice.find(params[:id])
      @company = @recurringinvoice.company
      @customer = @recurringinvoice.customer
      @items = @company.items
      @invoices = @recurringinvoice.invoices
    end
  end
  
  def update
    binding.pry
    @recurringinvoice = Recurringinvoice.find(params[:id])
    interval = params[:recurringinvoice][:interval]
    invoice_interval_number = params[:recurringinvoice][:invoice_interval_number].to_i
    last_invoice = Invoice.find(@recurringinvoice.last_invoice_id)
    
    if @recurringinvoice.interval != interval
      next_send_date = invoice_interval_number.send(interval).since(last_invoice.issue_date)
      params[:recurringinvoice][:next_send_date] = next_send_date
    end
    
    if @recurringinvoice.invoice_interval_number != invoice_interval_number
      invoice_interval_number.send(interval).since(last_invoice.issue_date)
      params[:recurringinvoice][:next_send_date] = next_send_date
    end
    
    if params[:recurringinvoice][:discontinue].present? 
       params[:recurringinvoice][:discontinued_user_id] = current_user.id
       params[:recurringinvoice][:discontinued_date] = Date.today
    end
    
    if @recurringinvoice.update_attributes(recurringinvoice_params)
      if @recurringinvoice.discontinue == true
        flash[:danger] = "Successfully discontinued Recurring Profile For #{@recurringinvoice.customer.customer_name}"
      else
        flash[:success] = "Successfully Updated Recurring Profile For #{@recurringinvoice.customer.customer_name}"
      end
      redirect_to recurringinvoice_path(@recurringinvoice)
    else
      flash[:danger] = @recurringinvoice.errors.full_messages.to_sentence
      render :edit
    end
  end
  
  def create_new_recurring_invoice(company, recurringinvoice)
    @recurringinvoice = recurringinvoice
    @company = company
    invoices = @company.invoices
    invoice_number = invoices.last == nil ? 1 : invoices.last.invoice_number.to_i + 1


    @invoice =  Invoice.new(company_id: @company.id, customer_id: @recurringinvoice.customer.id, invoice_number: invoice_number, user_id: @user.id, total: @recurringinvoice.total, status: "sent", issue_date: @recurringinvoice.original_issue_date, private_notes: @recurringinvoice.private_notes, customer_notes: @recurringinvoice.customer_notes, payment_terms: @recurringinvoice.payment_terms, po_number: @recurringinvoice.po_number, recurring: true, send_by_email: @recurringinvoice.send_by_email, send_by_text: @recurringinvoice.send_by_text, send_by_post: @recurringinvoice.send_by_post)

    if @invoice.save

      @recurringinvoice_items = RecurringinvoiceItem.where(recurringinvoice_id: @recurringinvoice.id)

      @recurringinvoice_items.each do |i|
        invoice_item = InvoiceItem.create(quantity: i.quantity, unit_cost: i.unit_cost, description: i.description, price: i.price, total: i.total, name: i.name, invoice_id: @invoice.id)
      end

     payment_url = "#{root_url}companies/#{@company.id}/payment?invoice_number=#{@invoice.invoice_number}&amount=#{@invoice.total}&email=#{@recurringinvoice.customer.customer_email}&name=#{@recurringinvoice.customer.customer_name.titleize}&address_one=#{@recurringinvoice.customer.address_one}&address_two=#{@recurringinvoice.customer.address_two}&city=#{@recurringinvoice.customer.city.titleize}&state=#{@recurringinvoice.customer.state}&post=#{@recurringinvoice.customer.postcode}&phone=#{@recurringinvoice.customer.phone}"


      pdf_url = "#{root_url}invoices/#{@invoice.id}/customer-invoice.pdf"


      $customerio.track(@recurringinvoice.customer.id,"invoice updated", customer_name: @invoice.customer.customer_name.titleize, invoice_number: @invoice.invoice_number, invoice_total: Money.new(@invoice.total, "USD").format, company_name: @company.company_name.titleize, company_user_email: current_user.email, company_logo: @company.logo, facebook_url: @company.facebook, google_url: @company.google, yelp_url: @company.yelp, contacts_emails: @contacts, payment_url: payment_url, status: @invoice.status.titleize, pdf_url: pdf_url)

      if @invoice.send_by_post == true
        send_letter
      end

     if @invoice.send_by_text == true
        invoice_url = "#{root_url}/invoices/#{@invoice.id}/customer-invoice"
        to_number = @invoice.customer.phone.gsub(/\s+/, "").gsub(/[^0-9A-Za-z]/, '')
        client = Twilio::REST::Client.new ENV["twilio_account_sid"], ENV["twilio_auth"]
        message = client.messages.create(from: '+12158834983', to: '+1' + to_number, body: "Thank you for using Service Pay #{@invoice.customer.customer_name.titleize}. A Link to your invoice from #{@company.company_name} is below: #{invoice_url}")
      end 

    else
      flash[:danger] = "There was an error creating your invoice from your recurring profile"
      render :new
    end
  end

  private

    def recurringinvoice_params
      params.require(:recurringinvoice).permit(:customer_id, :user_id, :company_id, :invoice_number, :original_issue_date, :private_notes, :customer_notes, :payment_terms, :discount, :po_number, :interval, :auto_paid, :total, :send_by_email, :send_by_post, :send_by_text, :number_of_invoices, :invoice_interval_number, :next_send_date, :number_sent, :discontinue, :discontinued_user_id, :discontinued_date, recurringinvoice_items_attributes: [:id, :quantity, :unit_cost, :description, :price, :total, :name, :_destroy])
    end

	def allowed_user
    @recurringinvoice = Recurringinvoice.find(params[:id])	
    @company = @recurringinvoice.company
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


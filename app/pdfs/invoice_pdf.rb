class InvoicePdf < Prawn::Document
	include ActionView::Helpers::NumberHelper

  def initialize(invoice, company, user, customer, left_to_pay, invoice_items, view)
		super()
		@invoice = invoice
		@company = company
		@user = user
		@customer = customer
		@left_to_pay = left_to_pay
    @invoice_items = invoice_items
		header
		content
    item_table
		footer
	end

	def header
		rectangle [0, 660], 1200, 30
		fill

		bounding_box([230,620], width: 300, height: 100) do
			text "Status: #{@invoice.status.titleize}"
		end

		bounding_box([20, 650], width: 300, height: 200) do 
			text "Invoice Number: #{@invoice.invoice_number}", color: 'ffffff'
			move_down 20
			text "Customer Info:"
			text "#{@customer.customer_name.titleize}"
			text "#{ @customer.address_one}"
			text "#{@customer.address_two.present? ?  @customer.address_two : nil }"
			text "#{@customer.city.titleize}, #{@customer.state} #{@customer.postcode}"
			text "#{number_to_phone(@customer.phone, area_code: true)}"
		end



		bounding_box([350, 650], :width => 300, :height => 200) do
		 text "Invoice Created By: #{@invoice.user.first_name.titleize} #{@invoice.user.last_name.titleize}", color: 'ffffff'
		 move_down 20
		 image open("#{ @company.logo.to_s }"), width: 200, height: 100
		end
	end

	def content
		move_down 20
		
		bounding_box([20, 500], :width => 300, :height => 200) do
			text "How Was This Invoice Sent?"
			text "#{@invoice.send_by_email? ? "Sent by Email" : nil}"
			text "#{@invoice.send_by_post? ? "Sent by Snail Mail" : nil}"
		end
		
		bounding_box([200, 500], :width => 300, :height => 200) do
			text "Is This A Recurring Invoice?"
			text "#{@invoice.recurring? ? "Yes, this is a recurring invoice" : "No, this is not a recurring invoice"}"
		end
    
    bounding_box([400,500], :width => 300, :height => 200) do
        text "<u><link href='http://servicepay-109358.nitrousapp.com:3000/companies/#{@company.id}/payment?invoice_number=#{@invoice.invoice_number}&amount=#{@left_to_pay}&email=#{@customer.customer_email}&name=#{@customer.customer_name.titleize}&address_one=#{@customer.address_one}&address_two=#{@customer.address_two}&city=#{@customer.city.titleize}&state=#{@customer.state}&post=#{@customer.postcode}&phone=#{@customer.phone}&invoice_id=#{@invoice.id}'>Pay Online" + "</link></u>", :inline_format => true
        text "<u><link href='http://servicepay-109358.nitrousapp.com:3000/invoices/#{@invoice.id}/customer-invoice'>View Invoice Online" + "</link></u>",  :inline_format => true
		end

		bounding_box([400, 400], :width => 300, :height => 200) do
			table ([["Invoice #", "#{@invoice.invoice_number}"], ["PO Number:", "#{@invoice.po_number}"], ["Invoice Date", "#{@invoice.issue_date.strftime("%m/%d/%Y")}"], ["Amount Due", "#{number_to_currency(@invoice.total.to_f / 100)}"]]) do
				cells.style(width: 80, height: 24, border: 1, border_color: '000000')
				columns(0).background_color = 'EEEEEE'
				columns(0).text_color = '000000'
			end
		end
	end

  def item_table
    def invoice_item_rows
      [["Item", "Description", "Unit Cost", "Quantity", "Price" ]] +
        @invoice_items.map do |i|
          [i.name, i.description, Money.new(i.unit_cost, "USD").format, i.quantity, Money.new(i.total, "USD").format]
        end
    end
    
		bounding_box([50, 280], :width => 300, :height => 200) do
      table (invoice_item_rows), width: 500 do 
				self.header = true
				self.rows(0).background_color = 'EEEEEE'
				self.rows(0).text_color = '000000'
			end
		end
  end

	def footer
		
		bounding_box([0, 120], :width => 300, :height => 200) do
			text "Private Notes", color: '3498db', size: 20
			stroke_horizontal_rule
			 text_box "#{@invoice.private_notes}", :at => [0, 170],
			 :width => 180,
			 :height => 50,
			 :overflow => :shrink_to_fit,
			 :min_font_size => 9
		end

		bounding_box([190, 120], :width => 300, :height => 200) do
			text "Notes For Clients", color: '3498db', size: 20
			stroke_horizontal_rule
			stroke_horizontal_rule
			 text_box "#{@invoice.customer_notes}", :at => [0, 170],
			 :width => 180,
			 :height => 50,
			 :overflow => :shrink_to_fit,
			 :min_font_size => 9
		end

		bounding_box([400, 120], :width => 300, :height => 200) do
			text "Payment Terms", color: '3498db', size: 20
			stroke_horizontal_rule
			stroke_horizontal_rule
			 text_box "#{@invoice.payment_terms}", :at => [0, 170],
			 :width => 170,
			 :height => 50,
			 :overflow => :shrink_to_fit,
			 :min_font_size => 9
		end

	end
end

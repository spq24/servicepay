class Payment < ActiveRecord::Base
	acts_as_paranoid
	
	belongs_to :coupon
	belongs_to :company
	belongs_to :customer
	belongs_to :invoice
	has_many   :reviews
	has_one    :refund

	accepts_nested_attributes_for :customer, reject_if: :unique_customer_for_company

	validates_presence_of :amount, :company_id

	validate :invoice_unpaid, on: :create

	validate :non_zero_or_negative

	validate :no_more_than_invoice_amount

	def invoice_unpaid
		if invoice_number.present?
			invoice = Invoice.find_by_invoice_number_and_company_id(invoice_number, company_id)
			if invoice.present? 
				if invoice.status == 'paid'
		    	  errors.add(:payment_id, "error. This invoice has already been paid")
		    	end
		    end
		end
	end

	def no_more_than_invoice_amount
		if invoice_number.present?
			invoice = Invoice.find_by_invoice_number_and_company_id(invoice_number, company_id)
			company = invoice.company
			payments_total = Payment.where(invoice_id: invoice.id).map { |t| t.amount }.sum
			left_to_pay = invoice.total - (payments_total)
			if invoice.present?
				if (amount) > left_to_pay
					errors.add(:payment_id, "error. You're paying more than what this invoice is for. There is only #{Money.new(left_to_pay, "USD").format} left to pay")
				end
			end
		end
	end

	def non_zero_or_negative
		if amount <= 0
			errors.add(:payment_id, "total must be greater than zero.")
		end
	end


end

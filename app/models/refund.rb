class Refund < ActiveRecord::Base
	acts_as_paranoid
	
	belongs_to :user
	belongs_to :payment
	belongs_to :company
	belongs_to :customer

	validates_presence_of :amount, :user_id, :company_id, :payment_id, :customer_id, :reason

	validate :refund_not_more_then_payment

	def refund_not_more_then_payment
		if Payment.find(payment_id).amount < amount
			errors.add(:refund_id, "amount can't be more then the original payment amount.")
		end
	end
end

class Invoice < ActiveRecord::Base
  
	belongs_to :company
	belongs_to :customer
	belongs_to :user
  belongs_to :recurringinvoice
	has_many   :payments
	has_many   :invoice_items, dependent: :destroy

  accepts_nested_attributes_for :invoice_items, allow_destroy: true

  validate :non_zero_or_negative, on: :update

	def non_zero_or_negative
		if total <= 0
			errors.add(:invoice_id, "total must be greater than zero.")
		end
	end
 

end

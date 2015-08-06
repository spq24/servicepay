class Invoice < ActiveRecord::Base

	belongs_to :company
	belongs_to :customer
	belongs_to :user
	has_many   :payments
	has_many   :invoice_items, dependent: :destroy

	accepts_nested_attributes_for :invoice_items



end

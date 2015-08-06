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

end

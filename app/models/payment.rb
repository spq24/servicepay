class Payment < ActiveRecord::Base
	acts_as_paranoid
	
	belongs_to :company
	has_one    :refund
	belongs_to :customer
	has_many   :reviews
	belongs_to :coupon

	accepts_nested_attributes_for :customer, reject_if: :unique_customer_for_company

	validates_presence_of :amount, :company_id

end

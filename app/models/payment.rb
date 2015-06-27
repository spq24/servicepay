class Payment < ActiveRecord::Base
	acts_as_paranoid
	
	belongs_to :company
	has_one    :refund
	belongs_to :customer
	has_many   :reviews

	accepts_nested_attributes_for :customer, :reject_if => :all_blank

	validates_presence_of :amount, :company_id
end

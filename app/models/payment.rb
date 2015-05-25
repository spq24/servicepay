class Payment < ActiveRecord::Base
	acts_as_paranoid
	
	belongs_to :user
	belongs_to :company
	has_one    :refund
	belongs_to :customer

	accepts_nested_attributes_for :customer, :reject_if => :all_blank
end

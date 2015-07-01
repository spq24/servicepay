class Payment < ActiveRecord::Base
	acts_as_paranoid
	
	belongs_to :company
	has_one    :refund
	belongs_to :customer
	has_many   :reviews



	validates_presence_of :amount, :company_id
end

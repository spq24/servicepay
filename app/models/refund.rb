class Refund < ActiveRecord::Base
	acts_as_paranoid
	
	belongs_to :user
	belongs_to :payment
	belongs_to :company
	belongs_to :customer

	validates_presence_of :amount, :user_id, :company_id, :payment_id, :customer_id, :reason
end

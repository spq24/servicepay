class Refund < ActiveRecord::Base
	acts_as_paranoid
	
	belongs_to :payment
	belongs_to :company
	belongs_to :user
	belongs_to :customer
end

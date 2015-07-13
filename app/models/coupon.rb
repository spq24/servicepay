class Coupon < ActiveRecord::Base
	belongs_to :company
	belongs_to :user
	belongs_to :customer
	has_many   :payments

	validates_presence_of :duration, :name, :currency, :company_id
	validates_uniqueness_of :name
end

class Coupon < ActiveRecord::Base
	belongs_to :company
	belongs_to :user

	validates_presence_of :duration, :name, :currency, :company_id
	validates_uniqueness_of :name
end

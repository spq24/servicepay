class Companyplan < ActiveRecord::Base

	has_many :companies, dependent: :delete_all
	belongs_to :user

	validates_presence_of :name, :amount, :user_id, :statement_descriptor, :currency, :interval
	validates_uniqueness_of :name

end

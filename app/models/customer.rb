class Customer < ActiveRecord::Base
	acts_as_paranoid

	belongs_to :company
	has_many :payments, dependent: :delete_all
	has_many :refunds, dependent: :delete_all
	has_many :reviews, dependent: :delete_all
end

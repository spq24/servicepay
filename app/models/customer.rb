class Customer < ActiveRecord::Base
	acts_as_paranoid
	attr_encrypted :stripe_token, :key => 'cyc2go7i6a'

	belongs_to :company
	has_many :payments, dependent: :delete_all
	has_many :refunds, dependent: :delete_all
	has_many :reviews, dependent: :delete_all
	has_many :subscriptions
	has_many :plans, -> { uniq }, through: :subscriptions, dependent: :delete_all
	has_many :invoices

	accepts_nested_attributes_for :subscriptions

	validate :unique_customer_for_company

	def unique_customer_for_company
		customer = Customer.find_by_customer_name_and_customer_email_and_company_id(customer_email, customer_name, company_id)
		if customer.present?
    		errors.add(:customer_id, "already exists. Customers are identified by their email, name, and address and a customer with these traits already exists.")
    	end
    end
end

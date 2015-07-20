class Plan < ActiveRecord::Base
    acts_as_paranoid
	belongs_to :company
	belongs_to :user
	has_many :subscriptions, dependent: :destroy
	has_many :customers, -> { uniq }, through: :subscriptions

	validates_presence_of :amount, :user_id, :company_id, :name, :interval, :statement_descriptor, :currency
	validate :unique_plan_for_company

	def unique_plan_for_company
		if Plan.find_by_name_and_company_id(name, company_id).present?
    		errors.add(:plan_id, "already exists. Plan names must be unique")
    	end
    end
end
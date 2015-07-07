class Plan < ActiveRecord::Base
    acts_as_paranoid
	belongs_to :company
	belongs_to :user
	has_many :subscriptions, dependent: :destroy
	has_many :customers, -> { uniq }, through: :subscriptions

	validates_presence_of :amount, :user_id, :company_id, :name, :interval, :statement_descriptor, :currency
end

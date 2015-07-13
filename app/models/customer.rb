class Customer < ActiveRecord::Base
	acts_as_paranoid
	attr_encrypted :stripe_token, :key => 'cyc2go7i6a'

	belongs_to :company
	has_many :payments, dependent: :delete_all
	has_many :refunds, dependent: :delete_all
	has_many :reviews, dependent: :delete_all
	has_many :subscriptions
	has_many :coupons
	has_many :plans, -> { uniq }, through: :subscriptions, dependent: :delete_all

	accepts_nested_attributes_for :subscriptions
end

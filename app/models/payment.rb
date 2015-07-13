class Payment < ActiveRecord::Base
	acts_as_paranoid
	
	belongs_to :company
	has_one    :refund
	belongs_to :customer
	has_many   :reviews
	belongs_to :coupon



	validates_presence_of :amount, :company_id


	def self.handle_coupon(options={})
		coupon = Coupon.find_by_name(options[:coupon])
		money = options[:money]
		if coupon.present
				count = coupon.redeemed_count + 1 
				coupon.save
				money_percent = money * coupon.percent_off.to_f / 100
				money_off = coupon.percent_off.nil? ? Money.new((coupon.amount_off.to_s.to_f * 100).to_i, "USD") : Money.new((money_percent.to_s.to_f * 100).to_i, "USD")
				amount_to_charge = money - money_off
		else
			return nil
		end
	end
end

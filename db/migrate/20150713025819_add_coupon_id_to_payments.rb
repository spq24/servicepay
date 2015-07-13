class AddCouponIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :coupon_id, :integer
  end
end

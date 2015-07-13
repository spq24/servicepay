class AddCouponIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :coupon_id, :integer
  end
end

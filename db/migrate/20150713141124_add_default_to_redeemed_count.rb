class AddDefaultToRedeemedCount < ActiveRecord::Migration
  def change
    change_column :coupons, :redeemed_count, :integer, default: 0
  end
end

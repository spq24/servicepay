class AddRedeemedCountToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :redeemed_count, :integer
  end
end

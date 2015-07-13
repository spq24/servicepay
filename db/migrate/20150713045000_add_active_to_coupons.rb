class AddActiveToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :active, :boolean, default: true
  end
end

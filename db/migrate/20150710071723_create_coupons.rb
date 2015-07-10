class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :duration
      t.integer :amount_off
      t.integer :currency
      t.integer :duration_in_months
      t.integer :max_redemptions
      t.integer :percent_off
      t.datetime :redeem_by
      t.timestamps
    end
  end
end

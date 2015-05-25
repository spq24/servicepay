class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.integer :user_id
      t.integer :company_id
      t.integer :amount
      t.string  :stripe_refund_id
      t.timestamps
    end
  end
end

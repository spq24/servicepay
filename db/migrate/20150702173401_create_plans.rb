class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :customer_id
      t.integer :amount
      t.string :currency
      t.string :interval
      t.integer :interval_count
      t.string :statement_descriptor
      t.timestamps
    end
  end
end

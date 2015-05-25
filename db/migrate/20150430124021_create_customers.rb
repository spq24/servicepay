class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.integer :company_id
      t.string  :customer_email
      t.string  :customer_name
      t.timestamps
    end
  end
end

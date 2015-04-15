class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :user_id
      t.integer :company_id
      t.integer :amount
      t.integer :reference_id
      t.timestamps
    end
  end
end

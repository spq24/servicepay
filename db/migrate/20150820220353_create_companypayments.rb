class CreateCompanypayments < ActiveRecord::Migration
  def change
    create_table :companypayments do |t|
      t.float :amount
      t.integer :company_id
      t.string :stripe_charge_id
      t.timestamps
    end
  end
end

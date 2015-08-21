class CreateCompanyplans < ActiveRecord::Migration
  def change
    create_table :companyplans do |t|
      t.string :name
      t.float :amount
      t.integer :user_id
      t.text :statement_descriptor
      t.string :currency
      t.string :interval
      t.timestamps
    end
  end
end

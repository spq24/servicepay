class CreateCustomerContacts < ActiveRecord::Migration
  def change
    create_table :customer_contacts do |t|
      t.string :name
      t.string :email
      t.string :number
      t.belongs_to :customer
      t.timestamps
    end
  end
end

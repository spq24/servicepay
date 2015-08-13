class DropCustomerContactsTwo < ActiveRecord::Migration
  def change
    drop_table :customer_contacts
  end
end

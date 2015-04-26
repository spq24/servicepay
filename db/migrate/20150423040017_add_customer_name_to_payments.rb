class AddCustomerNameToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :customer_name, :string
  end
end

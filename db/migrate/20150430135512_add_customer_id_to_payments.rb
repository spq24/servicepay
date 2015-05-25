class AddCustomerIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :customer_id, :integer
  end
end

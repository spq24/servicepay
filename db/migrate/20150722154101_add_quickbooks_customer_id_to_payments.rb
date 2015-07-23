class AddQuickbooksCustomerIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :quickbooks_customer_id, :integer
  end
end

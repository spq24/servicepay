class AddQuickbooksCustomerIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :quickbooks_customer_id, :integer
  end
end

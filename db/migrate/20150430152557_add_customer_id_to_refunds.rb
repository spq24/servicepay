class AddCustomerIdToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :customer_id, :integer
  end
end

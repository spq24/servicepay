class AddColumnsToInvoicesItems < ActiveRecord::Migration
  def change
    add_column :invoices_items, :unit_cost, :integer
    add_column :invoices_items, :quantity, :integer
    add_column :invoices_items, :price, :integer
  end
end

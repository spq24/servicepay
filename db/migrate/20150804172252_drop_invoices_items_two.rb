class DropInvoicesItemsTwo < ActiveRecord::Migration
  def change
    drop_table :invoices_items
  end
end

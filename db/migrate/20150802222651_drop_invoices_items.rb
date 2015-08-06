class DropInvoicesItems < ActiveRecord::Migration
  def change
    drop_table :invoice_item
  end
end

class AddNameToInvoiceItems < ActiveRecord::Migration
  def change
    add_column :invoice_items, :name, :string
  end
end

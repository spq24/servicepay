class AddTotalToInvoiceItems < ActiveRecord::Migration
  def change
    add_column :invoice_items, :total, :integer
  end
end

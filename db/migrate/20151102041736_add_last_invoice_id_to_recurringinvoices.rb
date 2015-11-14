class AddLastInvoiceIdToRecurringinvoices < ActiveRecord::Migration
  def change
    add_column :recurringinvoices, :last_invoice_id, :integer
  end
end

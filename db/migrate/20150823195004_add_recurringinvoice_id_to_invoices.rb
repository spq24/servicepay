class AddRecurringinvoiceIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :recurringinvoice_id, :integer
  end
end

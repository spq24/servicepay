class AddOriginalInvoiceIdToRecurringInvoices < ActiveRecord::Migration
  def change
    add_column :recurringinvoices, :original_invoice_id, :integer
  end
end

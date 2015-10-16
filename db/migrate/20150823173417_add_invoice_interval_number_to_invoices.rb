class AddInvoiceIntervalNumberToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :invoice_interval_number, :integer
  end
end

class AddNumberOfInvoicesToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :number_of_invoices, :integer
  end
end

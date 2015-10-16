class AddPdfToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :pdf, :string
  end
end

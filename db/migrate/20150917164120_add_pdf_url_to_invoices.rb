class AddPdfUrlToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :pdf_url, :string
  end
end

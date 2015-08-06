class AddDefaultInvoiceTermsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :default_invoice_terms, :text
  end
end

class AddInfoToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :info, :string
  end
end

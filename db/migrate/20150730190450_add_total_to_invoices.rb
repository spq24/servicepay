class AddTotalToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :total, :integer
  end
end

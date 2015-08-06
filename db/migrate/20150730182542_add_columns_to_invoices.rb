class AddColumnsToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :send_by_post, :boolean
    add_column :invoices, :send_by_email, :boolean
  end
end

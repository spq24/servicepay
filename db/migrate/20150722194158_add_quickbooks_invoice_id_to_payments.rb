class AddQuickbooksInvoiceIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :quickbooks_invoice_id, :integer
  end
end

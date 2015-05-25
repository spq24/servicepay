class AddInvoiceNumberToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :invoice_number, :string
  end
end

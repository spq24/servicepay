class AddPaymentDateToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :payment_date, :datetime
  end
end

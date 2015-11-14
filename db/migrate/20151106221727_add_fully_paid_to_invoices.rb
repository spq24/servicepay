class AddFullyPaidToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :fully_paid, :boolean, default: false
  end
end

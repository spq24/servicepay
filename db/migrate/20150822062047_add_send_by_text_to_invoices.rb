class AddSendByTextToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :send_by_text, :boolean
  end
end

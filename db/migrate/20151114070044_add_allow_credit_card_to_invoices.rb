class AddAllowCreditCardToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :allow_credit_card, :boolean
  end
end

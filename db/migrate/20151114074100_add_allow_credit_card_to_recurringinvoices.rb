class AddAllowCreditCardToRecurringinvoices < ActiveRecord::Migration
  def change
    add_column :recurringinvoices, :allow_credit_card, :boolean
  end
end

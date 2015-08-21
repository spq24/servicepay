class AddColumnsToInvoicesTwo < ActiveRecord::Migration
  def change
    add_column :invoices, :lob_letter_id, :string
    add_column :invoices, :lob_to_address_id, :string
    add_column :invoices, :lob_expected_delivery_date, :datetime
  end
end

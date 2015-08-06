class AddDescriptionToInvoicesItems < ActiveRecord::Migration
  def change
    add_column :invoices_items, :description, :string
  end
end

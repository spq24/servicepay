class CreateInvoicesItems < ActiveRecord::Migration
  def change
    create_table :invoices_items do |t|
      t.belongs_to :item
      t.belongs_to :invoice
      t.timestamps
    end
  end
end

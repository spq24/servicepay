class CreateInvoicesItems < ActiveRecord::Migration
  def change
    create_table :invoices_items do |t|
      t.string :name
      t.integer :unit_cost
      t.integer :quantity
      t.integer :price
      t.string :description
      t.integer :total
      t.belongs_to :recurringinvoice
      t.timestamps
    end
  end
end
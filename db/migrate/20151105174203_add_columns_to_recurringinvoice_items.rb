class AddColumnsToRecurringinvoiceItems < ActiveRecord::Migration
  def change
    add_column :recurringinvoice_items, :name, :string
    add_column :recurringinvoice_items, :unit_cost, :integer
    add_column :recurringinvoice_items, :quantity, :integer
    add_column :recurringinvoice_items, :price, :integer
    add_column :recurringinvoice_items, :recurringinvoice_id, :integer
    add_column :recurringinvoice_items, :description, :string
    add_column :recurringinvoice_items, :total, :integer
  end
end

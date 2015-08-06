class AddColumnToItems < ActiveRecord::Migration
  def change
    remove_column :items, :unit_cost, :string
    add_column :items, :unit_cost, :integer
  end
end

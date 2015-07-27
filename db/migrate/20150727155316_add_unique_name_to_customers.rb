class AddUniqueNameToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :unique_name, :string
  end
end

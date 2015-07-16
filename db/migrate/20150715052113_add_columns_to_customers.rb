class AddColumnsToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :address_one, :string
    add_column :customers, :address_two, :string
    add_column :customers, :city, :string
    add_column :customers, :state, :string
    add_column :customers, :country, :string, default: "usa"
    add_column :customers, :postcode, :string
  end
end

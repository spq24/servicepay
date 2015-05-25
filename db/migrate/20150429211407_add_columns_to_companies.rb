class AddColumnsToCompanies < ActiveRecord::Migration
  def change
  	add_column :companies, :publishable_key, :string
  	add_column :companies, :provider, :string
  	add_column :companies, :uid, :string
  	add_column :companies, :access_code, :string
  end
end

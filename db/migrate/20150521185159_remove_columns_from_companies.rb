class RemoveColumnsFromCompanies < ActiveRecord::Migration
  def down
  	remove_column :companies, :uid
  	remove_column :companies, :access_code
  	remove_column :companies, :publishable_key
  end
end

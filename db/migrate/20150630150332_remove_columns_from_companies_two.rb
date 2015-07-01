class RemoveColumnsFromCompaniesTwo < ActiveRecord::Migration
  def change
    remove_column :companies, :publishable_key, :string
    remove_column :companies, :access_code, :string
    remove_column :companies, :uid, :string
  end
end

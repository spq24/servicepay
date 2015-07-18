class RemoveColumnsFromCompanies2 < ActiveRecord::Migration
  def change
    remove_column :companies, :quickbooks_token, :string
    remove_column :companies, :quickbooks_secret, :string
    remove_column :companies, :quickbooks_realm_id, :string
  end
end

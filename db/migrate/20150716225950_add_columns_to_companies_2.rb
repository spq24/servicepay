class AddColumnsToCompanies2 < ActiveRecord::Migration
  def change
    add_column :companies, :encrypted_quickbooks_token, :string
    add_column :companies, :encrypted_quickbooks_secret, :string
    add_column :companies, :encrypted_quickbooks_realm_id, :string
  end
end

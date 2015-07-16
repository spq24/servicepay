class AddToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :quickbooks_token, :string
    add_column :companies, :quickbooks_secret, :string
    add_column :companies, :quickbooks_realm_id, :string
  end
end

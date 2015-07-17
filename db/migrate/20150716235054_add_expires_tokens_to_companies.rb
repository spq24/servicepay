class AddExpiresTokensToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :quickbooks_token_expires_at, :datetime
    add_column :companies, :quickbooks_reconnect_token_at, :datetime
  end
end

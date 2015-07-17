class AddDefaultsToQuickbooksColumns < ActiveRecord::Migration
  def change
    change_column :companies, :quickbooks_token_expires_at, :datetime, default: 6.months.from_now
    change_column :companies, :quickbooks_reconnect_token_at, :datetime, default: 5.months.from_now
  end
end

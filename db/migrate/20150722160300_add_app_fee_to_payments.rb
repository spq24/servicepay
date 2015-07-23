class AddAppFeeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :app_fee, :float
  end
end

class AddDefaultToApplicationFee < ActiveRecord::Migration
  def change
    change_column :companies, :application_fee, :float, default: 0.8
  end
end

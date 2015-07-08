class ChangeApplicationFeeColumnTypeInCompanies < ActiveRecord::Migration
  def change
    change_column :companies, :application_fee, :float
  end
end

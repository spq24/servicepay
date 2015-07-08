class AddApplicationFeeToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :application_fee, :integer
  end
end

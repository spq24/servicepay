class AddCompanyplanIdToCompanypayments < ActiveRecord::Migration
  def change
    add_column :companypayments, :companyplan_id, :integer
  end
end

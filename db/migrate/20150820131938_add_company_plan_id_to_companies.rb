class AddCompanyPlanIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :companyplan_id, :integer
  end
end

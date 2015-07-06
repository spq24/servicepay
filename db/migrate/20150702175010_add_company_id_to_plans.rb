class AddCompanyIdToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :company_id, :integer
  end
end

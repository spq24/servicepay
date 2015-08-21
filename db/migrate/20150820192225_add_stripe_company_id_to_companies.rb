class AddStripeCompanyIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :stripe_company_id, :string
  end
end

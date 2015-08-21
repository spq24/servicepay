class AddStripeKinertiaCompanyIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :stripe_kinertia_company, :integer
  end
end

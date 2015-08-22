class AddStripeSubscriptionIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :stripe_subscription_id, :string
  end
end

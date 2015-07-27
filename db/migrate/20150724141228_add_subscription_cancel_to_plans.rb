class AddSubscriptionCancelToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :subscription_cancel, :boolean
  end
end

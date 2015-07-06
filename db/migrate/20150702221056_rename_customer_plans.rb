class RenameCustomerPlans < ActiveRecord::Migration
  def change
    rename_table :customer_plans, :customers_plans
  end
end

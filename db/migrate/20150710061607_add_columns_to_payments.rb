class AddColumnsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :plan_id, :integer
    add_column :payments, :subscription, :boolean
  end
end

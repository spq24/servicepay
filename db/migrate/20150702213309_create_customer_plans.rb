class CreateCustomerPlans < ActiveRecord::Migration
  def change
    create_table :customer_plans, id: false do |t|
	  t.belongs_to :plan, index: true
      t.belongs_to :customer, index: true
    end
  end
end

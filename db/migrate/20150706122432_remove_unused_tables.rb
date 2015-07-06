class RemoveUnusedTables < ActiveRecord::Migration
  def change
    drop_table :customers_plans
    drop_table :activities
    drop_table :friendly_id_slugs
  end
end

class AddColumnsToItems < ActiveRecord::Migration
  def change
    add_column :items, :company_id, :integer
    add_column :items, :user_id, :integer
  end
end

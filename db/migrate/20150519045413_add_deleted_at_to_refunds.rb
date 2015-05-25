class AddDeletedAtToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :deleted_at, :datetime
    add_index :refunds, :deleted_at
  end
end

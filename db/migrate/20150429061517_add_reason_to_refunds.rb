class AddReasonToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :reason, :string
  end
end

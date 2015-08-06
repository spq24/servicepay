class AddQuickbooksRefundIdToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :quickbooks_refund_id, :integer
  end
end

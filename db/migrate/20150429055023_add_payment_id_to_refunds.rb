class AddPaymentIdToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :payment_id, :integer
  end
end

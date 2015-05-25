class AddRefundIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :stripe_refund_id, :string
  end
end

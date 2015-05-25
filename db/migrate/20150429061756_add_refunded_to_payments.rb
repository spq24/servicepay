class AddRefundedToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :refunded, :boolean
  end
end

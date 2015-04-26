class AddStripeUidToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :stripe_uid, :string
  end
end

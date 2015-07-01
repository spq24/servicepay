class AddEncryptedStripeTokenToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :encrypted_stripe_token, :string
    remove_column :companies, :encrypted_stripe_token, :string
  end
end

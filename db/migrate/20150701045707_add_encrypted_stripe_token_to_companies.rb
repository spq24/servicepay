class AddEncryptedStripeTokenToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :encrypted_stripe_token, :string
  end
end

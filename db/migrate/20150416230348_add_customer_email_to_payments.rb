class AddCustomerEmailToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :customer_email, :string
  end
end

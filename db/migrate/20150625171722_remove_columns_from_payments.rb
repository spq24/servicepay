class RemoveColumnsFromPayments < ActiveRecord::Migration
  def change
  	remove_column :payments, :customer_name, :string
  	remove_column :payments, :customer_email, :string

  end
end

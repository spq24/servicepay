class AddAccessCodeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :access_code, :string
  end
end

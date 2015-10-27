class AddPaymentDateToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_date, :datetime
  end
end

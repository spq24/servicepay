class AddLast4ToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :last_4, :string
  end
end

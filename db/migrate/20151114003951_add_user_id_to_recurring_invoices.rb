class AddUserIdToRecurringInvoices < ActiveRecord::Migration
  def change
    add_column :recurringinvoices, :user_id, :integer
  end
end

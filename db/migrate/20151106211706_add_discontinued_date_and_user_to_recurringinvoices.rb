class AddDiscontinuedDateAndUserToRecurringinvoices < ActiveRecord::Migration
  def change
    add_column :recurringinvoices, :discontinued_date, :datetime
    add_column :recurringinvoices, :discontinued_user_id, :integer
  end
end

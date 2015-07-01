class RemoveColumnsFromPaymentsTwo < ActiveRecord::Migration
  def change
    remove_column :payments, :user, :integer
    remove_column :payments, :reference_id, :integer
    remove_column :payments, :stripe_uid, :string
    remove_column :payments, :access_code, :string
  end
end

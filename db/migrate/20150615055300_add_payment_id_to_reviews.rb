class AddPaymentIdToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :payment_id, :integer
  end
end

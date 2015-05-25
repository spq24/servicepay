class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :company_id
      t.integer :customer_id
      t.string  :score
      t.text    :comments
      t.boolean :google
      t.boolean :yelp
      t.boolean :facebook
      t.boolean :email
      t.timestamps
    end
  end
end

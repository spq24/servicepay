class Reallyaddencryptedcolumns < ActiveRecord::Migration
  def change
  	add_column :companies, :encrypted_publishable_key, :string
  	add_column :companies, :encrypted_uid, :string
  	add_column :companies, :encrypted_access_code, :string
  end
end

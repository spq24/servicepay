class CreateRecurringinvoiceItems < ActiveRecord::Migration
  def change
    create_table :recurringinvoice_items do |t|

      t.timestamps
    end
  end
end

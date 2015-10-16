class CreateRecurringinvoices < ActiveRecord::Migration
  def change
    create_table :recurringinvoices do |t|
      t.integer :customer_id
      t.integer :company_id
      t.string  :invoice_number
      t.text    :private_notes
      t.text    :customer_notes
      t.text    :payment_terms
      t.string  :status
      t.float   :discount
      t.string  :po_number
      t.boolean :discontinue
      t.string  :interval
      t.datetime :next_send_date
      t.boolean :auto_paid
      t.boolean :send_by_post
      t.boolean :send_by_text
      t.boolean :send_by_email
      t.integer :total
      t.integer :invoice_interval_number
      t.integer :number_of_invoices
      t.integer :number_sent
      t.timestamps
    end
  end
end

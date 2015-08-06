class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer  :customer_id
      t.integer  :user_id
      t.integer  :company_id
      t.string   :invoice_number, default: "00000001"
      t.datetime :issue_date
      t.text     :private_notes
      t.text     :customer_notes
      t.text     :payment_terms
      t.boolean  :draft
      t.string   :status
      t.float    :discount
      t.string   :po_number
      t.boolean  :recurring
      t.string   :interval
      t.datetime :recurring_send_date
      t.boolean  :auto_paid
      t.string   :contact_type
      t.timestamps
    end
  end
end

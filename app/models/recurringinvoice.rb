class Recurringinvoice < ActiveRecord::Base
  belongs_to :company
  belongs_to :customer
  has_many :invoices
end

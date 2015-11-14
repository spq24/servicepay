class Recurringinvoice < ActiveRecord::Base
  belongs_to :company
  belongs_to :customer
  belongs_to :user
  has_many :invoices
  has_many :recurringinvoice_items, dependent: :destroy
  
  accepts_nested_attributes_for :recurringinvoice_items, allow_destroy: true
  
  validates_presence_of :customer_id, :user_id, :company_id, :invoice_interval_number
  
  validate :non_zero_or_negative
  
  def non_zero_or_negative
		if total <= 0
      errors.add(:recurringinvoice_id, "total must be greater than zero.")
		end
	end
  
  def active?
    discontinue == nil || discontinue ==  false
  end
  
  def discontinued?
    discontinue == true
  end
  
  def more_to_send?
    if number_of_invoices == nil
      return true
    elsif number_of_invoices != number_sent
      return true
    else
      return false
    end
  end
  
  def invoices_done?
    number_of_invoices == number_sent
  end
end

class Recurringinvoice < ActiveRecord::Base
  belongs_to :company
  belongs_to :customer
  belongs_to :user
  has_many :invoices
  has_many :recurringinvoice_items, dependent: :destroy
  
  accepts_nested_attributes_for :recurringinvoice_items, allow_destroy: true
  
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

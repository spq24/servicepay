class Company < ActiveRecord::Base
  acts_as_paranoid
  mount_uploader :logo, LogoUploader
  
  attr_encrypted :uid, :key => 'cOko1MRaIF'
  attr_encrypted :access_code, :key => 'qzH7QaFvzB'
  attr_encrypted :publishable_key, :key => 'w5rBp5WDkO'
  attr_encrypted :quickbooks_token, :key => '8U0tPdF0ZL'
  attr_encrypted :quickbooks_secret, :key => 'fBTb76HU0C'
  attr_encrypted :quickbooks_realm_id, :key => 'uh4qRJgn8n'
  
  has_many :users, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :plans, dependent: :destroy
  has_many :coupons, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :companypayments
  has_many :recurringinvoices
  belongs_to :companyplan
  
  accepts_nested_attributes_for :users, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :company_name, :address_one, :city, :state, :postcode, :phonenumber, :website_url, :if => :active?


  def active?
    status == 'active'
  end
  
end

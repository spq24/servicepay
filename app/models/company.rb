class Company < ActiveRecord::Base
  acts_as_paranoid
  attr_encrypted :uid, :key => 'cOko1MRaIF'
  attr_encrypted :access_code, :key => 'qzH7QaFvzB'
  attr_encrypted :publishable_key, :key => 'w5rBp5WDkO'
  mount_uploader :logo, LogoUploader
  
  has_many :users, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :reviews, dependent: :destroy
  
  accepts_nested_attributes_for :users, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :company_name, :address_one, :city, :state, :postcode, :phonenumber, :website_url, :if => :active?


  def active?
    status == 'active'
  end
  
end

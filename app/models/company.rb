class Company < ActiveRecord::Base
  mount_uploader :logo, LogoUploader
  
  has_many :users
  has_many :payments
  
  accepts_nested_attributes_for :users, :reject_if => :all_blank, :allow_destroy => true
  
end

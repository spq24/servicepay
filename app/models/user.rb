class User < ActiveRecord::Base
  acts_as_paranoid	
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  
  belongs_to :company
  has_many :refunds
  has_many :plans
  has_many :coupons
  
end

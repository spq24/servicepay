class User < ActiveRecord::Base
  acts_as_paranoid	
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  
  belongs_to :company
  has_many :payments
  has_many :refunds
  
end

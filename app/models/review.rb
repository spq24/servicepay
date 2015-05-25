class Review < ActiveRecord::Base
	acts_as_paranoid
	
	belongs_to :customer
	belongs_to :company
end

class Payment < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: :company

	belongs_to :user
	belongs_to :company
end

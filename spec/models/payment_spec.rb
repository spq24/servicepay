require 'rails_helper'

describe Payment do 

	it  { should validate_presence_of(:amount) }
	it  { should validate_presence_of(:company_id) }
	it  { should belong_to(:company) }
	it  { should belong_to(:customer) }
	#it  { should accept_nested_attributes_for :customers }

end
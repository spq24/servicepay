require 'rails_helper'

describe Review do 

	it  { should validate_presence_of(:score) }
	it  { should belong_to(:company) }
	it  { should belong_to(:customer) }
	it  { should belong_to(:payment) }

end
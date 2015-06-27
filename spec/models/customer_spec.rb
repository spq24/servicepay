require 'rails_helper'

describe Customer do 

	it  { should belong_to(:company) }
	it  { should have_many(:reviews) }
	it  { should have_many(:payments) }
	it  { should have_many(:refunds) }

end
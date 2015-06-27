require 'rails_helper'

describe Company do 

	it  { should have_many(:users) }
	it  { should have_many(:payments) }
	it  { should have_many(:refunds) }
	it  { should have_many(:customers) }
	it  { should have_many(:reviews) }

end
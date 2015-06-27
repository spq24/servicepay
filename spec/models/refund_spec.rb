require 'rails_helper'

describe Refund do 

	it  { should validate_presence_of(:amount) }
	it  { should validate_presence_of(:user_id) }
	it  { should validate_presence_of(:company_id) }
	it  { should validate_presence_of(:payment_id) }
	it  { should validate_presence_of(:customer_id) }
	it  { should validate_presence_of(:reason) }
	it  { should belong_to(:company) }
	it  { should belong_to(:customer) }
	it  { should belong_to(:payment) }

end
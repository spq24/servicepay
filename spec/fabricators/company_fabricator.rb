Fabricator(:company) do
	company_name { Faker::Company.name }
	address_one { Faker::Address.street_name }
	city { Faker::Address.city }
	state { Faker::Address.state }
	zip { Faker::Address.zip_code }
	phonenumber { Faker::PhoneNumber.phone_number }
	website_url "www.domain.com"
	status true
	terms true
end
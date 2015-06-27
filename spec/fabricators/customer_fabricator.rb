Fabricator(:customer) do
	customer_email { Faker::Internet.email }
	customer_name { Faker::Name.name }
end
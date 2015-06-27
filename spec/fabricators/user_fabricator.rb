Fabricator(:user) do
	email { Faker::Internet.email }
	password { Faker::Internet.password(8) }
	first_name { Faker::Name.first_name }
	last_name { Faker::Name.last_name }
end


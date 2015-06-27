Fabricator(:review) do
	score 10
	comments { Faker::Lorem.sentence }
end
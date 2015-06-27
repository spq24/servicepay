Fabricator(:refund) do 
	amount 400
	reason "contractor request"
	user
	company
	payment
	customer
end
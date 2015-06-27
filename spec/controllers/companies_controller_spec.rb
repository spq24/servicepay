require 'rails_helper'

describe CompaniesController do 

	describe "GET show" do

		context "reacts to authenticated users" do
			log_in_user

			it "sets current_user" do				
				subject.current_user.should_not be_nil
			end

			it "sets @company" do
				company = Fabricate(:company)
				get :show, id: company.id
				expect(assigns(:company)).to eq(company)
			end

			#it "sets @payments" do
			#	company = Fabricate(:company) 
			#	payment1, payment2 = Fabricate(:payment, company: company), Fabricate(:payment, company: company)
			#	get :show, id: company.id
			#	expect(assigns(:payments)).to match_array([payment1, payment2])
			#end


		end
	end
end
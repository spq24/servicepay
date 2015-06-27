require 'rails_helper'


describe PaymentsController do

	describe "GET new" do
		let(:company) { Fabricate(:company) }

		before do
		  get :new, id: company.id
		end

		it "sets @company" do
			expect(assigns(:company)).to be_instance_of(Company)
		end

		it "sets @payment" do
		  expect(assigns(:payment)).to be_instance_of(Payment)
		end
	end
end
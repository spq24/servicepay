require 'rails_helper'

describe StripeWrapper do

	describe StripeWrapper::Charge do
		let(:valid_token) {
			Stripe::Token.create(
				  :card => {
				    :number => "4242424242424242",
				    :exp_month => 4,
				    :exp_year => 2020,
				    :cvc => 314
				  },
			).id
		}

		let(:declined_card_token) {
			Stripe::Token.create(
				  :card => {
				    :number => "4000000000000002",
				    :exp_month => 4,
				    :exp_year => 2020,
				    :cvc => 314
				  },
			).id
		}

	
		describe ".create" do
			it "makes a successful charge"
			it "makes a card declined charge"
			it "returns the error message for declined charges."
		end
	end
end
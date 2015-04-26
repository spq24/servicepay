module StripeWrapper
	class Charge
		attr_reader :error_message, :response

		def initialize(options={})
			@response = options[:response]
			@error_message = options[:error_message]
		end

		def self.create(options={})
			begin
				charge = Stripe::Charge.create({
					amount: 1000,
					currency: "usd",
					source: options[:source],
					description: "test charge",
					application_fee: 123
				}, 
					{stripe_account: options[:uid]}
				)
				new(response: charge)
			rescue Stripe::CardError => e
				new(error_message: e.message)
			end
		end

		def successful?
			charge.present?
		end
	end

	class Customer
		attr_reader :response, :error_message
	
		def initialize(options={})
			@response = options[:response]
			@error_message = options[:error_message]
		end

		def self.create(options={})
			begin
			customer = Stripe::Customer.create({
				source: options[:source],
				email: options[:customer_email],
				description: "Service Pay"
				},
			    {stripe_account: options[:uid]}
			)
			new(response: customer)
			rescue Stripe::CardError => e
			  new(error_message: e.message)
			end
		end

		def successful?
			customer.present?
		end

		def customer_token
			customer.id
		end
	end
end

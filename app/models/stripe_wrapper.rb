module StripeWrapper
	class Charge
		attr_reader :error_message, :response

		def initialize(options={})
			@response = options[:response]
			@error_message = options[:error_message]
		end

		def self.create(options={})
			begin
				response = Stripe::Charge.create({
					amount: options[:amount],
					currency: "usd",
					customer: options[:customer],
					description: "Charge for service",
					application_fee: options[:fee]
				}, 
					{stripe_account: options[:uid]}
				)
				new(response: response)
			rescue Stripe::CardError => e
				new(error_message: e.message)
			end
		end

		def successful?
			response.present?
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
				email: options[:customer_email]
				},
			    {stripe_account: options[:uid]}
			)
			new(response: customer)
			rescue Stripe::CardError => e
			  new(error_message: e.message)
			end
		end

		def successful?
			response.present?
		end

		def customer_token
			response.id
		end
	end

	class Company
		attr_reader :response, :error_message
	
		def initialize(options={})
			@response = options[:response]
			@error_message = options[:error_message]
		end

		def self.create(options={})
			begin
			response = Stripe::Customer.create(
				source: options[:source],
				description: options[:description],
				plan: options[:plan]
				)
			new(response: response)
			rescue Stripe::CardError => e
			  new(error_message: e.message)
			end
		end

		def successful?
			response.present?
		end

		def customer_token
			response.id
		end
	end
end

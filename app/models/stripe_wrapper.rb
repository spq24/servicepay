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
					amount: 1000,
					currency: 'usd',
					source: token,
				}, stripe_account: current_user.uid)
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
			response = Stripe::Customer.create(
				card: options[:card],
				email: options[:user_email],
				description: "TrackLocal Customer #{options[:company_id]}",
				plan: "2"
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

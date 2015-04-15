Stripe.api_key = ENV["STRIPE_SECRET"]


StripeEvent.configure do |events|
  events.subscribe 'charge.succeeded' do |event|
  	company = Company.where(customer_token: event.data.object.customer).first
    Payment.create(company: company, amount: event.data.object.amount, reference_id: event.data.object.invoice)
  end

  events.subscribe 'charge.failed' do |event|
  	company = Company.where(customer_token: event.data.object.customer).first
  end
end
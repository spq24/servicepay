Stripe.api_key = ENV["STRIPE_SECRET"]

StripeEvent.configure do |events|
  events.subscribe 'invoice.payment_succeeded' do |event|
  	customer = Customer.find_by_stripe_token(event.data.object.customer)
  	charge = Stripe::Charge.retrieve(event.data.object.charge)
  	stripe_customer = Stripe::Customer.retrieve(event.data.object.customer)
  	stripe_sub = stripe_customer.subscriptions.retrieve(event.data.object.subscription)
  	plan = Subscription.find_by_stripe_subscription_id(stripe_sub.id).plan_id
  	Payment.create(amount: event.data.object.total, customer: customer, company: customer.company, stripe_charge_id: event.data.object.charge, last_4: charge[:source][:last4], subscription: true, plan_id: plan)
  	$customerio.track(customer.id,"Invoice Receipt", customer_name: customer.customer_name, amount: event.data.object.total, company_user_email: customer.company.users.first.email, company_logo: customer.company.logo, facebook_url: customer.company.facebook, google_url: customer.company.google, yelp_url: customer.company.yelp)
  end

   events.subscribe 'charge.failed' do |event|
  	user = User.where(customer_token: event.data.object.customer).first
    user.deactivate!
  end
end
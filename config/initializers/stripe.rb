Stripe.api_key = ENV["STRIPE_SECRET"]

StripeEvent.configure do |events|
  events.subscribe 'invoice.payment_succeeded' do |event|
  	customer = Customer.find_by_stripe_token(event.data.object.customer)
  	charge = Stripe::Charge.retrieve(event.data.object.charge) unless event.data.object.discount.present?
  	stripe_customer = Stripe::Customer.retrieve(event.data.object.customer)
    discount = event.data.object.discount
    coupon = Coupon.find_by_name(discount[:coupon][:id]) if discount.present?
    binding.pry
  	stripe_sub = stripe_customer.subscriptions.retrieve(event.data.object.subscription)
  	plan = Subscription.find_by_stripe_subscription_id(stripe_sub.id).plan_id
    if discount.present?
      Payment.create(amount: event.data.object.total, customer: customer, company: customer.company, last_4: stripe_customer.sources.retrieve(stripe_customer[:default_source])[:last4], subscription: true, plan_id: plan, coupon_id: coupon.id)
    else
      Payment.create(amount: event.data.object.total, customer: customer, company: customer.company, stripe_charge_id: event.data.object.charge, last_4: charge[:source][:last4], subscription: true, plan_id: plan)
  	end
    $customerio.track(customer.id,"Invoice Receipt", customer_name: customer.customer_name, amount: event.data.object.total, company_user_email: customer.company.users.first.email, company_logo: customer.company.logo, facebook_url: customer.company.facebook, google_url: customer.company.google, yelp_url: customer.company.yelp)
  end

   events.subscribe 'charge.failed' do |event|
  	user = User.where(customer_token: event.data.object.customer).first
    user.deactivate!
  end
end
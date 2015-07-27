Stripe.api_key = ENV["STRIPE_SECRET"]

StripeEvent.configure do |events|
  events.subscribe 'invoice.payment_succeeded' do |event|
  	customer = Customer.find_by_stripe_token(event.data.object.customer)
  	charge = Stripe::Charge.retrieve(event.data.object.charge) unless event.data.object.discount.present?
  	stripe_customer = Stripe::Customer.retrieve(event.data.object.customer)
    discount = event.data.object.discount
    coupon = Coupon.find_by_name(discount[:coupon][:id]) if discount.present?
  	stripe_sub = stripe_customer.subscriptions.retrieve(event.data.object.subscription)
  	plan = Subscription.find_by_stripe_subscription_id(stripe_sub.id).plan_id
    amount = Money.new((event.data.object.total.to_f).to_i, "USD")
    
    if discount.present?
      payment = Payment.create(amount: amount.cents , customer: customer, company: customer.company, stripe_charge_id: event.data.object.charge, last_4: stripe_customer.sources.retrieve(stripe_customer[:default_source])[:last4], subscription: true, plan_id: plan, coupon_id: coupon.id)
    else
      payment = Payment.create(amount: event.data.object.total, customer: customer, company: customer.company, stripe_charge_id: event.data.object.charge, last_4: charge[:source][:last4], subscription: true, plan_id: plan)
  	end
    
    $customerio.track(customer.id,"Invoice Receipt", customer_name: customer.customer_name, amount: event.data.object.total, company_user_email: customer.company.users.first.email, company_logo: customer.company.logo, facebook_url: customer.company.facebook, google_url: customer.company.google, yelp_url: customer.company.yelp)
    
    if customer.company.quickbooks_token.present?
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, customer.company.quickbooks_token, customer.company.quickbooks_secret)
      qb_payment = Quickbooks::Service::Payment.new
      qb_payment.access_token = oauth_client
      qb_payment.company_id = customer.company.quickbooks_realm_id
      qb_invoice = Quickbooks::Service::Invoice.new
      qb_invoice.access_token = oauth_client
      qb_invoice.company_id = customer.company.quickbooks_realm_id
    
      amount_charged = amount.format.delete('$')
      invoice = Quickbooks::Model::Invoice.new
      invoice.customer_id = payment.customer.quickbooks_customer_id
      invoice.txn_date = payment.created_at
      invoice.doc_number = payment.invoice_number
      invoice.private_note =  payment.customer.customer_name
      line_item = Quickbooks::Model::InvoiceLineItem.new
      line_item.amount = amount_charged
      line_item.description = "Customer Payment for: " + Plan.find(plan).name
      line_item.detail_type = "Customer Payment for: " + Plan.find(plan).name
      line_item.sales_item! do |detail|
        detail.unit_price = amount_charged
        detail.quantity = 1
      end

      invoice.line_items << line_item

      created_invoice = qb_invoice.create(invoice)
  
      if created_invoice.present?
        payment.update_attribute(:quickbooks_invoice_id, created_invoice.id)
      end                		

		  qb_pay = Quickbooks::Model::Payment.new
		  line = Quickbooks::Model::Line.new
      line.amount = amount_charged
      linked_transaction = Quickbooks::Model::LinkedTransaction.new
	    linked_transaction.txn_id = payment.quickbooks_invoice_id
	    linked_transaction.txn_type = 'Invoice'
      
      line.linked_transactions << linked_transaction
      qb_pay.line_items << line
      qb_pay.customer_id = customer.quickbooks_customer_id
      qb_pay.total = amount_charged
      qb_pay.private_note = payment.customer.customer_name

      response = qb_payment.create(qb_pay)

      if response.present?
            customer.update_attribute(:quickbooks_customer_id, response.customer_ref.value)
      end
    end 
  end
  
   events.subscribe 'charge.failed' do |event|
  	user = User.where(customer_token: event.data.object.customer).first
    user.deactivate!
  end
end
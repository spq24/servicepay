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
      qb_customer = Quickbooks::Service::Customer.new
      qb_customer.access_token = oauth_client
      qb_customer.company_id = customer.company.quickbooks_realm_id

      if customer.quickbooks_customer_id.nil?
          qb_cust = Quickbooks::Model::Customer.new
          customer_name_in_db = Customer.where(customer_name: customer.customer_name, company_id: customer.company.id).to_a
          if customer_name_in_db.count > 0
            customer_count = customer_name_in_db.count + 1
            unique_name = customer.customer_name + " " + customer_count.to_s
            unique_name = unique_name.length > 24 ? unique_name[0..23] + " " + customer_count.to_s : unique_name
          else
            unique_name = customer.customer_name[0..24]
          end
          customer.update_attribute(:unique_name, unique_name)
          qb_cust.given_name = unique_name
          qb_cust.fully_qualified_name = customer.customer_name
          phone = Quickbooks::Model::TelephoneNumber.new
          phone.free_form_number = customer.phone
          qb_cust.primary_phone = phone
          qb_cust.email_address = customer.customer_email
          address = Quickbooks::Model::PhysicalAddress.new
          address.line1 = customer.address_one
          address.line2 = customer.address_two
          address.city = customer.city
          address.country_sub_division_code = customer.state
          address.postal_code = customer.postcode
          qb_cust.billing_address = address
          response = qb_customer.create(qb_cust)
          if response.id.present?
            customer.update_attribute(:quickbooks_customer_id, response.id)
          end
      end



      amount_charged = amount.format.delete('$')
      invoice = Quickbooks::Model::Invoice.new
      invoice.customer_id = customer.quickbooks_customer_id
      invoice.txn_date = payment.created_at
      invoice.private_note =  customer.customer_name + " " + "Payment For #{Plan.find(plan).name} for #{payment.created_at.strftime("%m/%Y")}"
      line_item = Quickbooks::Model::InvoiceLineItem.new
      line_item.amount = amount_charged
      line_item.description = "Customer Payment for: " + Plan.find(plan).name
      line_item.detail_type = "SalesItemLineDetail"
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
      qb_pay.private_note = customer.customer_name + " " + "Payment For #{Plan.find(plan).name} for #{payment.created_at.strftime("%m/%Y")}"

      response = qb_payment.create(qb_pay)

      if response.present?
        payment.update_attribute(:quickbooks_customer_id, response.customer_ref.value)
      end
    end 
  end
    
   events.subscribe 'charge.succeeded' do |event|
     company = Company.find_by_stripe_company_id(event.data.object.customer)
     plan = Plan.find_by_name(event.data.object.plan)
     Companypayment.create(company_id: company.id, amount: event.data.object.amount, stripe_charge_id: event.data.object.id, companyplan_id: plan.id)
   end


   events.subscribe 'charge.failed' do |event|
  	user = User.where(customer_token: event.data.object.customer).first
    user.deactivate!
  end
end
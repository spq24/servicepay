ActiveAdmin.register Payment do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
   permit_params :company_id, :user_id, :amount, :customer_email, :customer_name, :refunded, :stripe_refund_id, :application_fee, :subscription, :plan_id, :quickbooks_customer_id, :invoice_id, :app_fee
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end

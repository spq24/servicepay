ActiveAdmin.register Customer do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
   permit_params :customer_name, :customer_email, :company_id, :customer_id, :address_one, :address_two, :city, :country, :postcode, :state, :phone
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end

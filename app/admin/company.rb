ActiveAdmin.register Company do


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
   permit_params :company_name, :logo, :description, :phonenumber, :website_url, :address_one, :address_two, :city, :state, :postcode, :facebook, :google, :yelp, :application_fee
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end

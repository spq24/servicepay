class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
 


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:first_name, :last_name, :company_name)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:first_name, :last_name, :company_name)
    end
  end
end
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :authenticate_user!

  def stripe_connect
    @user = current_user
    @company = @user.company
    if @user.update_attributes({
      provider: request.env["omniauth.auth"].provider,
      uid: request.env["omniauth.auth"].uid,
      access_code: request.env["omniauth.auth"].credentials.token,
      publishable_key: request.env["omniauth.auth"].info.stripe_publishable_key
    })
      # anything else you need to do in response..
      sign_in @user, :event => :authentication
      set_flash_message(:success, :success, :kind => "Stripe") if is_navigational_format?
      redirect_to company_path(@company)
    else
      session["devise.stripe_connect_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end

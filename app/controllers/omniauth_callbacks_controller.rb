class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :authenticate_user!

  def stripe_connect
    @user = current_user
    @company = @user.company
    if @company.update_attributes({
      provider: request.env["omniauth.auth"].provider,
      uid: request.env["omniauth.auth"].uid,
      access_code: request.env["omniauth.auth"].credentials.token,
      publishable_key: request.env["omniauth.auth"].info.stripe_publishable_key
    })
      add_to_cio
      sign_in @user, :event => :authentication
      set_flash_message(:success, :success, :kind => "Stripe") if is_navigational_format?
      redirect_to company_path(@company)
    else
      session["devise.stripe_connect_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  protected

  def add_to_cio
    $customerio.identify(
      id: @user.id,
      created_at: @user.created_at,
      email: @user.email,
      first_name: @user.first_name,
      last_name: @user.last_name,
      company_name: Company.find(@user.company_id).company_name,
      company_id: @user.company_id,
      user: true
    )
  end
end

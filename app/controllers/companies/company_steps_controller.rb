class Companies::CompanyStepsController < ApplicationController
  include Wicked::Wizard
  
  steps :company_info, :user_signup
  
  def show
    @user = current_user
    @company = Company.find(params[:company_id])
    render_wizard
  end
  
  def update
    @user = current_user
  	@company = Company.find(params[:company_id])
    case step
    when :company_info
      if @company
        @company.update_attributes(company_params)
        @company.status = true if step == :company_info
        @company.save
        flash[:success] = "Awesome, just some info about you and we'll be ready to go!"
        render_wizard @company
      else
        @error_message = "Oops something went wrong. Please check the information you entered"
        self
      end
    when :user_signup
      sign_in(@user, bypass: true) # needed for devise
    end
  end

  private
  	def finish_wizard_path
      @user = current_user
      session[:user_id] = @user.id
  	  company_path
  	end

    def company_params
        params.require(:company).permit(:company_name, :description, :logo, :phonenumber, :website_url, :address_one, :address_two, :city, :state, :postcode, :facebook, :google, :yelp, :status, :terms, users_attributes: [:id, :email, :first_name, :last_name, :password])
    end


end

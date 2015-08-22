class Companies::CompanyStepsController < ApplicationController
  include Wicked::Wizard
  
  steps :company_info, :user_signup
  
  def show
    @user = current_user
    @company = Company.find(params[:company_id])
    @plans = Companyplan.where.not(custom: true)
    render_wizard
  end
  
  def update
    @user = current_user
  	@company = Company.find(params[:company_id])
    @plans = Companyplan.all

    case step
    when :company_info
      if @company
        binding.pry
        plan = Companyplan.find(params[:company][:companyplan_id])

        stripe_company = StripeWrapper::Company.create(source: params[:stripeToken], description: @company.company_name, plan: plan.name)

        if stripe_company.successful?
            @company.update_attributes(company_params)
            @company.update_attribute(:stripe_company_id, stripe_company.response.id)
            @company.update_attribute(:stripe_subscription_id, stripe_company.response[:subscriptions][:data][0][:id])
            @company.update_attribute(:status, true) if step == :company_info
            flash[:success] = "Awesome, just some info about you and we'll be ready to go!"
            render_wizard @company
        else
            flash[:danger] = stripe_company.error_message
            render :company_info
        end
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
  	  company_path(@user.company)
  	end

    def company_params
        params.require(:company).permit(:company_name, :description, :logo, :phonenumber, :website_url, :address_one, :address_two, :city, :state, :postcode, :facebook, :google, :yelp, :status, :terms, :companyplan_id, :stripe_company_id, users_attributes: [:id, :email, :first_name, :last_name, :password])
    end


end

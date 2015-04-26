class CompaniesController < ApplicationController
  before_action :authenticate_user!, if: :user_signed_in?
  before_filter :correct_user, only: [:edit, :update, :show, :destroy]

  def new
    @company = Company.new
  end
  
  def create
    @company = Company.create(company_params)
    if @company
      flash[:success] = "Thank you for signing up! Tell Us Some Info About Your Company So We Can Better Serve You"
      redirect_to company_company_steps_path(@company)
    else
      flash[:danger] = "We Couldn't Create Your Company"
      render :new
    end
  end
  
  def edit
    @company = Company.find(params[:id])
    @company_users = @company.users
    @user = current_user
  end
  
  def update
    @user = current_user
    @company = Company.find(params[:id])
      if @company.update_attributes(company_params)
        if URI(request.referer).path == edit_company_path
          flash[:success] = "You have successfully edited Your Account"
          redirect_to edit_company_path
        else
          flash[:success] = "Awesome, just a little bit more info about your company"
          redirect_to wizard_path(:company_info)
        end
    else
      @status = :failed
      @error_message = "Oops something went wrong. Please check the information you entered"
      self
    end
  end
  
  
  def show
    @user = current_user
    @company = @user.company
    @payments = @company.payments
    @revenue = @payments.sum(:amount)
    @activities = PublicActivity::Activity.order("created_at desc").where(owner_id: @company.id)
  end
  
  def destroy
  end
  
  private
  
  def company_params
      params.require(:company).permit(:company_name, :logo, :phonenumber, :website_url, :address_one, :address_two, :city, :state, :postcode, users_attributes: [:id, :email, :first_name, :last_name, :password])
  end

  def correct_user
    @company = Company.find(params[:id])
    redirect_to root_path unless @company.users.include?(current_user)
    flash[:danger] = "You are not authorized to view that account. Please login as a user associated with that company" unless @company.users.include?(current_user)
  end
end

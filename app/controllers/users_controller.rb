class UsersController < ApplicationController
	before_action :authenticate_user!, only: [:show, :index, :edit]

	def index
		@user = current_user
		@company = @user.company
		@company_users = @company.users.all if @user.company.present?
	end

	def show
		@user = current_user
		@company = @user.company
	end

	private
  
    def after_sign_in_path_for(resource)
    	redirect_to company_path(@user.company)
    end
end

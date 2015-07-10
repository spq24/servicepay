class CouponsController < ApplicationController
  before_action :authenticate_user!, if: :user_signed_in?
  before_action :allowed_user, only: [:edit, :update, :show, :destroy]

	def new
		@user = current_user
		@company = @user.company
		@coupon = Coupon.new
	end

	def create
		@user = current_user
		@company = @user.company
		@coupon = Coupon.new(name: params[:coupon][:name], duration: params[:coupon][:duration], amount_off: params[:coupon][:amount_off], currency: "usd", duration_in_months: params[:coupon][:duration_in_months], max_redemptions: params[:coupon][:max_redemptions], percent_off: params[:coupon][:percent_off], redeem_by: params[:coupon][:redeem_by], company_id: @company.id)
		if @coupon.valid?
			Stripe.api_key = @company.access_code
			stripe_coupon = Stripe::Coupon.create(id: params[:coupon][:name], duration: params[:coupon][:duration], amount_off: params[:coupon][:amount_off], currency: "usd", duration_in_months: params[:coupon][:duration_in_months], max_redemptions: params[:coupon][:max_redemptions], percent_off: params[:coupon][:percent_off], redeem_by: params[:coupon][:redeem_by])
			if stripe_coupon.id.present?
				@coupon = Coupon.create(coupon_params)
				flash[:success] = "#{@coupon.name} created"
				redirect_to coupons_path
			else
				flash[:danger] = "There was a problem creating your plan. #{result.error_message}"
			end				
		else
		  flash[:danger] = "There was a problem creating your plan. #{@plan.errors.full_messages.to_sentence}"
		  render :new
		end	
	end


	def show
	end

	def index
		@user = current_user
		@company = @user.company
		@coupons = @company.coupons.reverse
	end

	def edit
	end

	def update
	end

	def destroy
	end

    private

    def coupon_params
      params.require(:coupon).permit(:name, :duration, :amount_off, :currency, :duration_in_months, :max_redemptions, :percent_off, :redeem_by, :company_id, :user_id)
    end

	def allowed_user
	  @coupon = Coupon.find(params[:id])
	  @company = @coupon.company
	  redirect_to root_path unless @company.users.include?(current_user)
	  flash[:danger] = "You are not authorized to view that account. Please login as a user associated with that company" unless @company.users.include?(current_user)
	end
end
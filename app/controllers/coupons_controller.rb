class CouponsController < ApplicationController
  before_action :authenticate_user!, if: :user_signed_in?
  before_action :allowed_user, only: [:show, :destroy]

	def new
		@user = current_user
		@company = @user.company
		@coupon = Coupon.new
	end

	def create
		@user = current_user
		@company = @user.company
		amount_off_stripe = params[:coupon][:amount_off].empty? ? nil : params[:coupon][:amount_off].to_i * 100
		amount_off = params[:coupon][:amount_off].empty? ? nil : params[:coupon][:amount_off].to_i
		percent_off = params[:coupon][:percent_off].empty? ? nil : params[:coupon][:percent_off]
		duration_in_months = params[:coupon][:duration_in_months].empty? ? nil : params[:coupon][:duration_in_months].to_i
		max_redemptions = params[:coupon][:max_redemptions].empty? ? nil : params[:coupon][:max_redemptions].to_i
		redeem_by_date_stripe = params[:coupon][:redeem_by].empty? ? nil : DateTime.strptime(params[:coupon][:redeem_by], "%m/%d/%Y").to_i
		redeem_by_date = params[:coupon][:redeem_by].empty? ? nil : DateTime.strptime(params[:coupon][:redeem_by], "%m/%d/%Y").to_date
		@coupon = Coupon.new(name: params[:coupon][:name], duration: params[:coupon][:duration], amount_off: amount_off, currency: "usd", duration_in_months: duration_in_months, max_redemptions: max_redemptions, percent_off: percent_off, redeem_by: redeem_by_date, company_id: @company.id)
		if @coupon.valid?
			Stripe.api_key = @company.access_code
			stripe_coupon = Stripe::Coupon.create(id: params[:coupon][:name], amount_off: amount_off_stripe, currency: "usd", duration: params[:coupon][:duration], duration_in_months: duration_in_months, max_redemptions: max_redemptions, percent_off: percent_off, redeem_by: redeem_by_date_stripe)
			if stripe_coupon.id.present?
				@coupon = Coupon.create(name: params[:coupon][:name], duration: params[:coupon][:duration], amount_off: amount_off, currency: "usd", duration_in_months: duration_in_months, max_redemptions: max_redemptions, percent_off: percent_off, redeem_by: redeem_by_date, company_id: @company.id, user_id: @user.id)
				flash[:success] = "#{@coupon.name} created"
				redirect_to coupons_path
			else
				flash[:danger] = "There was a problem creating your coupon. #{result.error_message}"
			end				
		else
		  flash[:danger] = "There was a problem creating your coupon. #{@coupon.errors.full_messages.to_sentence}"
		  render :new
		end	
	end


	def show
		@user = current_user
		@company = @user.company
		@coupon = Coupon.find(params[:id])
	end

	def index
		@user = current_user
		@company = @user.company
		@coupons = @company.coupons.reverse
		@coupons_redeemed_sum = @coupons.map(&:redeemed_count).sum
	end

	def destroy
	  @user = current_user
	  @company = @user.company
	  Stripe.api_key = @company.access_code
	  response = Stripe::Coupon.retrieve(@coupon.name).delete
	  if response[:deleted] == true
		@coupon = Coupon.find(params[:id])
		@coupon.active = false
		@coupon.save
		flash[:success] = "Coupon De-Activated."
		redirect_to coupons_path
	  else
	  	flash[:danger] = "We couldn't delete your coupon right now. Please try again soon"
	  	redirect_to coupons_path
	  end
	end

    private

    def coupon_params
      params.require(:coupon).permit(:name, :duration, :amount_off, :currency, :duration_in_months, :max_redemptions, :percent_off, :redeem_by, :company_id, :user_id, :customer_id, :active)
    end

	def allowed_user
	  @coupon = Coupon.find(params[:id])
	  @company = @coupon.company
	  redirect_to root_path unless @company.users.include?(current_user)
	  flash[:danger] = "You are not authorized to view that account. Please login as a user associated with that company" unless @company.users.include?(current_user)
	end
end
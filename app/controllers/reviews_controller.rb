class ReviewsController < ApplicationController
	before_action :authenticate_user!, if: :user_signed_in?
	before_filter :allowed_user, only: [:show, :edit, :update, :destroy]

	def new
		@review = Review.new
	end

	def create
		@review = Review.create(review_params)
		if @review.valid?
		    if @review
		      $customerio.track(@review.customer_id, "review", score: @review.score, customer_name: @review.customer.customer_name, company_user_email: User.find_by(company_id: @review.company_id).email, reviewed: true, company_name: @review.company.company_name)
		      $customerio.identify(id: @review.customer_id, reviewed: true)
		      flash[:success] = "Thank you for your review! Just One More Question."
		      if @review.score.to_i > 8
            redirect_to happy_review_path(id: params[:review][:payment_id])
		      elsif @review.score.to_i.between?(7,8)
            redirect_to okay_review_path(id: params[:review][:payment_id])
		      else
            redirect_to sad_review_path(id: params[:review][:payment_id])
		      end
		    else
		      flash[:danger] = "We Couldn't Create Your Review Something Went Wrong"
		      render :new
		    end
		else
		  redirect_to payment_path(@review.payment)
		  flash[:danger] = "Please Click a Number Between 1 and 10 and re-submit"
		end
	end

	def show
		@user = current_user
		@company = @user.company
		@review = Review.find(params[:id])
	end

	def index
		@user = current_user
		@company = @user.company
		@reviews = @company.reviews.order(created_at: :desc)
		@promoters = @reviews.select { |r| r.score.to_i > 7 }
		@passives = @reviews.select { |r| r.score.to_i.between?(7,8) }
		@detractors = @reviews.select { |r| r.score.to_i < 7 }
		@nps = (@promoters.count.to_f / @reviews.count.to_f * 100 - @detractors.count.to_f / @reviews.count.to_f * 100)
	end

	def update
		@review = Review.find(params[:id])
		@company = @review.company
		@customer = @review.customer
	    if @review.update_attributes(review_params)
	      $customerio.track(@review.customer_id, "review comments", comments: @review.comments, customer_name: @review.customer.customer_name, company_user_email: User.find_by(company_id: @review.company_id).email, reviewed: true, company_name: @review.company.company_name)
	      flash[:success] = "Thank You For Your Comments"
	      redirect_to final_review_path(@company)
	    else
	      @error_message = "Oops something went wrong. Please check the information you entered"
	      self
	    end
	end

	def destroy
	  Review.find(params[:id]).destroy
	  flash[:success] = "Review Deleted."
	  redirect_to reviews_path
	end

	def happy
	    @payment = Payment.find(params[:id])
	    @company = @payment.company
	    @customer = @payment.customer
	    @review = Review.find_by(payment_id: @payment.id)
	    @google = @company.google.include?("http") ? @company.google : "https://"+@company.google
	    @yelp = @company.yelp.include?("http") ? @company.yelp : "http://"+@company.yelp
	    @facebook = @company.facebook.include?("http") ? @company.facebook : "http://"+@company.facebook
	end

	def okay
	    @payment = Payment.find(params[:id])
	    @company = @payment.company
	    @customer = @payment.customer
	    @review = Review.find_by(payment_id: @payment.id)
	end

	def sad
	    @payment = Payment.find(params[:id])
	    @company = @payment.company
	    @customer = @payment.customer
	    @review = Review.find_by(payment_id: @payment.id)
	end

	def final
	    @company = Company.find(params[:id])
	end

	private
	  
	def review_params
	    params.require(:review).permit(:customer_id, :company_id, :score, :comments, :payment_id, :facebook, :google, :yelp, :email)
	end

	def allowed_user
		@review = Review.find(params[:id])	
    	@company = @review.company
    	redirect_to root_path unless @company.users.include?(current_user)
    	flash[:danger] = "You are not authorized to view that account. Please login as a user associated with that company" unless @company.users.include?(current_user)
    end
end

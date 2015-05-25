class ReviewsController < ApplicationController

	def new
		@review = Review.new
	end

	def create
		@review = Review.create(review_params)
	    if @review
	      binding.pry
	      $customerio.track(@review.customer_id, "review", score: @review.score, reviewed: true)
	      flash[:success] = "Thank you for your review! Just One More Question."
	      if @review.score.to_i > 8
	      	redirect_to happy_review_path(id: params[:review][:company_id])
	      elsif @review.score.to_i.between?(7,8)
	      	redirect_to okay_review_path(id: params[:review][:company_id])
	      else
	      	redirect_to sad_review_path(id: params[:review][:company_id])
	      end
	    else
	      flash[:danger] = "We Couldn't Create Your Review Something Went Wrong"
	      render :new
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
		@customer = @company.customers.last
	    if @review.update_attributes(review_params)
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
		@company = Company.find(params[:id])
		@customer = @company.customers.last
		@review = @customer.reviews.last
	end

	def okay
		@company = Company.find(params[:id])
		@customer = @company.customers.last
		@review = @customer.reviews.last
	end

	def sad
		@company = Company.find(params[:id])
		@customer = @company.customers.last
		@review = @customer.reviews.last
	end

	def final
	    @company = Company.find(params[:id])
	end

	private
	  
	def review_params
	    params.require(:review).permit(:customer_id, :company_id, :score, :comments, :facebook, :google, :yelp, :email)
	end
end

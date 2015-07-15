class StaticPagesController < ApplicationController

	def faq
	end

	def tc
	end

	def learn
		@company = Company.new
	end

	def vision
	end

end
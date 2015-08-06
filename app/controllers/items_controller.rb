class ItemsController < ApplicationController
	before_action :authenticate_user!
	before_filter :allowed_user, only: [:show, :edit, :update, :destroy]
	before_action :set_qb_service, only: [:index, :edit, :update, :create, :destroy]

	def new
    @user = current_user
    @company = @user.company
    @item = Item.new
	end

	def create
    @user = current_user
    @company = @user.company
    unit_cost = Money.new((params[:item][:unit_cost].to_f * 100).to_i, "USD")
    @item = Item.new(name: params[:item][:name], description: params[:item][:description], unit_cost: unit_cost.cents, quantity: params[:item][:quantity], company_id: @company.id, user_id: @user.id)
    if @item.valid?
      @item = Item.create(name: params[:item][:name], description: params[:item][:description], unit_cost: unit_cost.cents, quantity: params[:item][:quantity], company_id: @company.id, user_id: @user.id)
      if @item.present?      
        flash[:success] = "Successfully created new item #{@item.name.titleize}"
        redirect_to items_path
      else
        flash[:danger] = "There was a problem creating your item. #{@item.errors.full_messages.to_sentence}"
      end
    else
      flash[:danger] = "There was a problem creating your item. #{@item.errors.full_messages.to_sentence}"
      render :new
    end
	end

	def edit
    @user = current_user
    @company = @user.company
    @item = Item.find(params[:id])
	end

	def update
    @user = current_user
    @company = @user.company
    @item = Item.find(params[:id])
    unit_cost = Money.new((params[:item][:unit_cost].to_f * 100).to_i, "USD")
    if @item.update_attributes(name: params[:item][:name], description: params[:item][:description], unit_cost: unit_cost.cents, quantity: params[:item][:quantity])
      flash[:success] = "Successfully updated #{@item.name.titleize}"
      redirect_to items_path
    else
      flash[:danger] = @item.errors.full_messages.to_sentence
      render :edit
    end
	end

	def index
    @user = current_user
    @company = @user.company
    @items = @company.items
	end

	def destroy
    if @item.destroy
      flash[:success] = "Successfully deleted item #{@item.name.titleize}"
      redirect_to items_path
    else
      flash[:danger] = @item.errors.full_messages.to_sentence
    end
	end

	private

	def item_params
    params.require(:item).permit(:name, :description, :unit_cost, :quantity, :company_id, :user_id)
	end

	def allowed_user
	  @item = Item.find(params[:id])	
      @company = @item.company
      redirect_to root_path unless @company.users.include?(current_user)
      flash[:danger] = "You are not authorized to view that account. Please login as a user associated with that company" unless @company.users.include?(current_user)
    end

 	def set_qb_service
 	  @user = current_user
 	  @company = @user.company
      oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, @company.quickbooks_token, @company.quickbooks_secret)
      @qb_customer = Quickbooks::Service::Customer.new
      @qb_customer.access_token = oauth_client
      @qb_customer.company_id = @company.quickbooks_realm_id
      @qb_payment = Quickbooks::Service::Payment.new
      @qb_payment.access_token = oauth_client
      @qb_payment.company_id = @company.quickbooks_realm_id
      @qb_invoice = Quickbooks::Service::Invoice.new
      @qb_invoice.access_token = oauth_client
      @qb_invoice.company_id = @company.quickbooks_realm_id
  end

end

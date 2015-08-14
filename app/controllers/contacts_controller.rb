class ContactsController < InheritedResources::Base
  before_action :authenticate_user!, if: :user_signed_in?
  before_action :set_up_basics

  def new
  	@contact = Contact.new
  	@customer = Customer.find(params[:customer_id])
  end

  def create
  	@customer = Customer.find(params[:contact][:customer_id])
  	@contact = Contact.new(contact_params)

  	if @contact.valid?
  		@contact = Contact.create(contact_params)
  		flash[:success] = "#{@contact.name.titleize} has been created as a Contact!"
  		redirect_to customer_path(@customer)
  	else
  		flash[:danger] = "Could not create contact #{@contact.errors.full_messages.to_sentence}"
		render :new
  	end
  end
  
  def edit
    @contact = Contact.find(params[:id])
    @customer = Customer.find(params[:customer_id])
  end

  def update
    @contact = Contact.find(params[:id])
    @customer = Customer.find(params[:customer_id])
    if @contact.update_attributes(contact_params)
      flash[:success] = "#{@contact.name.titleize}'s information has been updated"
      redirect_to customer_path(@customer)
    else
      flash[:danger] = "There was a problem updating information for #{@contact.name.titleize}. #{@contact.errors.full_messages.to_sentence}"
      render :edit
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @customer = Customer.find(params[:customer_id])
    @contact.destroy
    flash[:success] = "#{@contact.name.titleize} has been deleted."
    redirect_to customer_path(@customer)
  end



  private

    def contact_params
      params.require(:contact).permit(:name, :email, :number, :customer_id)
    end

    def set_up_basics
		  @user = current_user
		  @company = @user.company
    end
end


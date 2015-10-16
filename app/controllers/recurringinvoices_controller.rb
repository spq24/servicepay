class RecurringinvoicesController < InheritedResources::Base
  
  def index
    @user = current_user
    @company = @user.company
    @recurringinvoices = @company.recurringinvoices
  end

  private

    def recurringinvoice_params
      params.require(:recurringinvoice).permit()
    end
end


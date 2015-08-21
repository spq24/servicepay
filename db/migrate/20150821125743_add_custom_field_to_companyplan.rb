class AddCustomFieldToCompanyplan < ActiveRecord::Migration
  def change
    add_column :companyplans, :custom, :boolean
  end
end

class AddDescriptionToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :description, :text_area
  end
end

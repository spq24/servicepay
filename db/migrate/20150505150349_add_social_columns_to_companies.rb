class AddSocialColumnsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :facebook, :string
    add_column :companies, :google, :string
    add_column :companies, :yelp, :string
  end
end

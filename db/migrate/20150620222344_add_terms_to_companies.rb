class AddTermsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :terms, :boolean
  end
end

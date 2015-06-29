class DeleteZipFromCompanies < ActiveRecord::Migration
  def change
    remove_column :companies, :zip, :string
  end
end

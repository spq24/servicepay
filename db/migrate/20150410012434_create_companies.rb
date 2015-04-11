class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :company_name
	    t.string   :address_one
	    t.string   :address_two
	    t.string   :city
	    t.string   :state
	    t.string   :zip
	    t.string   :postcode
	    t.string   :country
	    t.string   :phonenumber
	    t.string   :website_url
      t.timestamps
    end
  end
end

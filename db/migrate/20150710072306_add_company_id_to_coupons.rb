class AddCompanyIdToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :company_id, :integer
  end
end

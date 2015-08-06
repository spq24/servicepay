class Item < ActiveRecord::Base

  belongs_to :user
  belongs_to :company
  
  validates_presence_of :name, :description, :unit_cost
  validate :unique_item_for_company, on: :create
  
  def unique_item_for_company
    if Item.find_by_name_and_company_id(name, company_id).present?
      errors.add(:item_id, "already exists. Item names must be unique")
    end
  end
end

class Contact < ActiveRecord::Base

  belongs_to :customers


	validates_presence_of :name, :email, :number, :customer_id

  validate :unique_contact_for_customer, on: :create

	def unique_contact_for_customer
		contact = Contact.find_by_email_and_customer_id(email, customer_id)
		if contact.present?
    		errors.add(:contact_id, "already exists. Customer contacts are identified by their email and a customer contact with this email already exists for this customer.")
    	end
    end
end

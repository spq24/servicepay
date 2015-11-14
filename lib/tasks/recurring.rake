

namespace :recurringinvoices do
  desc "Check recurring profiles and create invoice if necessary"
  task check: :environment do
    profiles = Recurringinvoice.all
    
    profiles.each do |p|
      if p.next_send_date == Date.today
        RecurringinvoicesController.new.create_new_recurring_invoice(p.company, p, "servicepay.me")
      end
    end
	end
end
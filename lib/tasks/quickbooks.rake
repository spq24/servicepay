namespace :quickbooks do
  desc "Check recurring profiles and create invoice if necessary"
  task renew_tokens: :environment do
    companies = Company.all
    
    companies.each do |record|
      if record.quickbooks_reconnect_token_at.present?
        if record.quickbooks_reconnect_token_at.strftime("%m/%d/%Y") == Date.today.strftime("%m/%d/%Y")
          access_token = OAuth::AccessToken.new($qb_oauth_consumer, record.quickbooks_token, record.quickbooks_secret)
          service = Quickbooks::Service::AccessToken.new
          service.access_token = access_token
          service.company_id = record.quickbooks_realm_id
          result = service.renew

          # result is an AccessTokenResponse, which has fields +token+ and +secret+
          # update your local record with these new params
          record.quickbooks_token = result.token
          record.quickbooks_secret = result.secret
          record.quickbooks_token_expires_at = 6.months.from_now.utc
          record.quickbooks_reconnect_token_at = 5.months.from_now.utc
          record.save!
        end
      end
    end      
	end
end
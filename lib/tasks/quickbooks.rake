namespace :quickbooks do
  desc "Check recurring profiles and create invoice if necessary"
  task renew_token: :environment do
    expiring_tokens = Company.where(quickbooks_reconnect_token_at: Date.today)
    binding.pry
    
    expiring_tokens.each do |record|
      access_token = OAuth::AccessToken.new($qb_oauth_consumer, record.access_token, record.access_secret)
      service = Quickbooks::Service::AccessToken.new
      service.access_token = access_token
      service.company_id = record.company_id
      result = service.renew

      # result is an AccessTokenResponse, which has fields +token+ and +secret+
      # update your local record with these new params
      record.access_token = result.token
      record.access_secret = result.secret
      record.token_expires_at = 6.months.from_now.utc
      record.reconnect_token_at = 5.months.from_now.utc
      record.save!
    end      
	end
end
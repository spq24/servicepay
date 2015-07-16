QB_KEY = ENV['quickbooks_consumer_key']
QB_SECRET = ENV['quickbooks_consumer_secret']

Quickbooks.sandbox_mode = true

$qb_oauth_consumer = OAuth::Consumer.new(QB_KEY, QB_SECRET, {
    :request_token_path   => "https://oauth.intuit.com/oauth/v1/get_request_token",
    :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
    :access_token_path    => "https://oauth.intuit.com/oauth/v1/get_access_token"
})
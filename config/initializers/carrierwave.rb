CarrierWave.configure do |config|
	  config.fog_credentials = {
	    provider:               'AWS',                        # required
	    aws_access_key_id:      ENV['aws_access_key_id'],                        # required
	    aws_secret_access_key:  ENV['aws_secret_access_key'],
      region:                'us-west-1'
	  }
    config.fog_directory  = 'servicepay'                          # required
	  config.fog_public     = false                                        # optional, defaults to true
	  config.fog_attributes = {'Cache-Control'=>"max-age=#{365.day.to_i}"} # optional, defaults to {}
end
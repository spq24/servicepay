CarrierWave.configure do |config|
	if Rails.env.production? || Rails.env.development?
	  config.fog_credentials = {
	    provider:               'AWS',                        # required
	    aws_access_key_id:      ENV['aws_access_key_id'],                        # required
	    aws_secret_access_key:  ENV['aws_secret_access_key']                        # required
	  }
	  config.fog_directory  = 'tracklocal'                          # required
	  config.fog_public     = false                                        # optional, defaults to true
	  config.fog_attributes = {'Cache-Control'=>"max-age=#{365.day.to_i}"} # optional, defaults to {}
	else
		config.storage = :file
		config.enable_processing = false
	end
end
if Rails.env.staging? || Rails.env.production?
			uri = URI.parse(ENV['REDISCLOUD_URL'])
			$redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
			# Resque.redis = $redis
else
			$redis = Redis.new	
			# Resque.redis = $redis
end
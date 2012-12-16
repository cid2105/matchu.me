require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'

  	Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
 	
 	Resque.after_fork do |job|
 		
    	ActiveRecord::Base.retrieve_connection

		if Rails.env.staging? || Rails.env.production?
			uri = URI.parse(ENV['REDISCLOUD_URL'])
			$redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
			Resque.redis = $redis
		else
			$redis = Redis.new	
			Resque.redis = $redis
		end

	end

end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

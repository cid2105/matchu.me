web: bundle exec rails server thin -p $PORT -e $RACK_ENV
worker: rake resque:work QUEUE=*

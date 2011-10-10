require './smspotify'

run Rack::URLMap.new \
  "/"       => Sinatra::Application,

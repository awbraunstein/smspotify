# -*- coding: utf-8 -*-
require './smspotify'

run Rack::URLMap.new \
  "/"       => Sinatra::Application,

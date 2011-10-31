# -*- coding: utf-8 -*-
log = File.new('log/sinatra.log', 'a')
$stdout.reopen(log)
$stderr.reopen(log)

require './smspotify'
run Sinatra::Application
require 'rubygems'
require 'twilio-ruby'
require 'hallon'
require 'sinatra'
requitre 'config'

# set up a client to talk to the Twilio REST API
@client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

@account = @client.account

@account.sms.messages.create(:from => '+12158746339', :to => '+15165265739', :body => 'Hey there!')



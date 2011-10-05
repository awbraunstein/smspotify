require 'rubygems'
require 'twilio-ruby'
#require 'hallon'
require 'sinatra'
require './config'


ENV['TWILIO_ACCOUNT_SID'] = 'AC211b4e7f967bbbf12edcf890057b3b62'
ENV['TWILIO_AUTH_TOKEN'] = '678f0bf63d6bc201b26075a0cb302270'

# set up a client to talk to the Twilio REST API
@client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

@account = @client.account

@account.sms.messages.create(:from => '+12158746339', :to => '+15165265739', :body => 'Hey there!')


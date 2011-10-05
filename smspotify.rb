require 'rubygems'
require 'twilio-ruby'
require 'hallon'

# put your own credentials here
account_sid = 'AC211b4e7f967bbbf12edcf890057b3b62'
auth_token = '678f0bf63d6bc201b26075a0cb302270'

# set up a client to talk to the Twilio REST API
@client = Twilio::REST::Client.new account_sid, auth_token

@account = @client.account

@account.sms.messages.create(:from => '+12158746339', :to => '+15165265739', :body => 'Hey there!')


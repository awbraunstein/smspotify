require 'rubygems'
require 'data_mapper'
require 'twilio-ruby'
require 'sinatra'
require './config'
require  'dm-migrations'
require './sp_requests'

##################### Database setup ####################
DataMapper.setup(:default, 'sqlite:development.db')

class Choice
  include DataMapper::Resource

  property :id,         Serial    # An auto-increment integer key
  property :number,     String    # A varchar type string, for short strings
  property :a,          String
  property :b,          String
  property :c,          String
  property :d,          String
  property :created_at, DateTime  # A DateTime, for any date you might like.
end

DataMapper.finalize
DataMapper.auto_migrate!
########################################################


# set up a client to talk to the Twilio REST API
@client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
@account = @client.account

get '/' do
  "Nope, chuck testa"
end

post '/' do  
  body = params[:Body]
  from = params[:From]
  
  @rec = Choice.first(:number => from)

  if @rec.nil?
    reults = Sp_search.get_sp_uris(body)
    @sp_request = Choice.create(
                       :number => from,
                       :a => results[0][:uri],
                       :b => results[1][:uri],
                       :c => results[2][:uri],
                       :d => results[3][:uri],
                       :created_at => Time.now
                       )

  else
    
  end
  
  response = Twilio::TwiML::Response.new do |r|
    r.Sms "hello there #{params[:From]}"
  end
  "#{response.text}"
end

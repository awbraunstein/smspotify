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

account_sid= 'AC211b4e7f967bbbf12edcf890057b3b62'
auth_token = '678f0bf63d6bc201b26075a0cb302270'
# set up a client to talk to the Twilio REST API
@client = Twilio::REST::Client.new account_sid, auth_token
@account = @client.account


def request_helper(from,body)
  account_sid= 'AC211b4e7f967bbbf12edcf890057b3b62'
  auth_token = '678f0bf63d6bc201b26075a0cb302270'
  @client = Twilio::REST::Client.new account_sid, auth_token
  @account = @client.account
  if body.size > 0
    results = Sp_search.get_sp_uris(body)
    @sp_request = Choice.create(
                                :number => from,
                                :a => results[0][:uri],
                                :b => results[1][:uri],
                                :c => results[2][:uri],
                                :d => results[3][:uri],
                                :created_at => Time.now
                                )
    text_response =  "respond with:\n"
    text_response +="a for #{results[0][:name]}\n"
    text_response +="b for #{results[1][:name]}\n"
    text_response +="c for #{results[2][:name]}\n"
    text_response +="d for #{results[3][:name]}"
    

    @account.sms.messages.create(
                                 :from => '+12158746339',
                                 :to => from,
                                 :body => text_response
                                 )
    # response = Twilio::TwiML::Response.new do |r|
    #   r.Sms = text_response
    # end
    # "#{response.text}"
  end
end


get '/' do
  "Nope, chuck testa"
end

post '/' do  
  body = params[:Body]
  from = params[:From]
  
  @rec = Choice.first(:number => from)
    
  if @rec.nil?
    request_helper(from,body)
  else
    body.downcase!
    uri = ""
    case body
    when "a"
      uri=@rec.a
    when "b"
      uri=@rec.b
    when "c"
      uri=@rec.c
    when "d"
      uri=@rec.d
    else
      @rec.destroy
      request_helper(body)
    end
    if uri != ""
      response = Twilio::TwiML::Response.new do |r|
        r.Sms uri
      end
      "#{response.text}"
    end
  end
end


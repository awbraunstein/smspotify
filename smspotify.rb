require 'rubygems'
require 'twilio-ruby'
require 'hallon'
require 'sinatra'
require 'net/http'
require 'json'

require './config'

# set up a client to talk to the Twilio REST API
@client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
@account = @client.account

get '/' do
  "welcome to smspotify"
end

post '/' do

  response = Twilio::TwiML::Response.new do |r|
    r.Sms 'hello there'
  end
  "#{response.text}"
  puts reponse.text
end

class GetArtists
  # @spotify_artist_get_request = "http://ws.spotify.com/search/1/artist.json?q="
  @spotify_get_request = "http://ws.spotify.com/search/1/track.json?q="
    
  def GetArtists.get_spotify_URIs(artists)
    uri_list = []
    artists.each do |artist|
      encoded_artist = artist.gsub(/\s/, '+')
      request_url = @spotify_get_request+encoded_artist
      data = Net::HTTP.get_response URI.parse(request_url)
      json_obj = JSON.parse(data.body)
      
      track_uri = json_obj["tracks"][0]["href"]
      
      p track_uri
      
      uri_list << track_uri
    end
    uri_list
  end  
  
end


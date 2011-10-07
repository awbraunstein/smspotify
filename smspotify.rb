# -*- coding: utf-8 -*-
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
#######################################################
############## HALLON SPOTIFY SETUP ###################

$session = Hallon::Session.initialize IO.read(ENV['HALLON_APPKEY']) do
  on(:log_message) do |message|
    puts "[LOG] #{message}"
  end
end

$session.login ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']

$session.wait_for(:logged_in) { |error| Hallon::Error.maybe_raise(error) }
$session.wait_for(:connection_error) do |error|
  $session.logged_in? or Hallon::Error.maybe_raise(error)
end
#######################################################


    

@playlist_uri = "spotify:user:awbraunstein:playlist:0QAdX8dGjNBSO9hBTYs9GU"

def request_helper(from,body)
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
    
    response = Twilio::TwiML::Response.new do |r|
      r.Sms text_response
     end
      "#{response.text}"
  end
end


get '/' do
  "Nope, chuck testa!"
end

post '/' do  
  body = params[:Body]
  from = params[:From]
  
  @rec = Choice.first(:number => from)
    
  if @rec.nil?
    return request_helper(from,body)
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
      return request_helper(from,body)
    end
    if uri != ""
      add_song_to_playlist (uri)
    end
  end
end


def add_song_to_playlist(uri)

  Resque.enqueue(Sp_add_track, uri)
  
end

module Sp_add_track

  @queue = :sp_task
  
  def self.perform(track_uri)

    puts "[LOG] Starting worker with #{track_uri}"
    playlist = Hallon::Playlist.new("spotify:user:awbraunstein:playlist:0QAdX8dGjNBSO9hBTYs9GU")
    $session.wait_for { playlist.loaded? }
    puts "[LOG] #{playlist.name}"
    track_uris = [track_uri]
    position = playlist.tracks.size    
    tracks = track_uris.map { |x| Hallon::Track.new(Hallon::Link.new(x)) }
    $session.wait_for { tracks.all?(&:loaded?) }
    puts "[LOG] Tracks made"
    FFI::MemoryPointer.new(:pointer, tracks.length) do |tracks_ary|
      tracks_ary.write_array_of_pointer tracks.map(&:pointer)      
      error = Spotify.playlist_add_tracks(playlist.pointer, tracks_ary, tracks.length, position, $session.pointer)
      Hallon::Error.maybe_raise(error)
    end
    puts "[LOG] Added tracks to playlist. Now waiting."
    $session.process_events
    $session.wait_for { not playlist.pending? } 
  end
end


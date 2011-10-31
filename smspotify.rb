# -*- coding: utf-8 -*-
# Copyright 2011 Andrew Braunstein. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#    1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 
#    2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY ANDREW BRAUNSTEIN ''AS IS'' AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
# NO EVENT SHALL ANDREW BRAUNSTEIN OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of Andrew Braunstein.
require 'rubygems'
require 'data_mapper'
require 'twilio-ruby'
require 'sinatra'
require './config'
require  'dm-migrations'
require './sp_requests'
require 'hallon'

##################### Database setup #################
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

$session.login! ENV['HALLON_USERNAME'], ENV['HALLON_PASSWORD']

puts "[LOG] Logged in as #{ENV['HALLON_USERNAME']}"


$playlist_uri = "spotify:user:awbraunstein:playlist:0QAdX8dGjNBSO9hBTYs9GU"
puts "Loading Playlist"

$playlist = Hallon::Playlist.new($playlist_uri)
$session.wait_for { $playlist.loaded? }
puts "[LOG] #{$playlist.name}"


#######################################################


    



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
  redirect '/index.html'
end

post '/' do  
  body = params[:Body]
  from = params[:From]

  puts "[LOG] #{body} from #{from}"

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
      puts "adding uri: #{uri}"
      add_song_to_playlist (uri)
    end
  end
end


def add_song_to_playlist(track_uri)

  puts "[LOG] #{$session.to_s}"
    
  puts "Loading Track"
  
  track = Hallon::Track.new(track_uri) 
  $session.wait_for { track.loaded? }
  $session.wait_for { not $playlist.pending? } 
  position = $playlist.tracks.size    
  puts "[LOG] Track made"
  tracks = [track]
  FFI::MemoryPointer.new(:pointer, 1) do |tracks_ary|
    tracks_ary.write_array_of_pointer tracks.map(&:pointer)      
    error = Spotify.playlist_add_tracks($playlist.pointer, tracks_ary, 1, position, $session.pointer)
    Hallon::Error.maybe_raise(error)
  end
  puts "[LOG] Added tracks to playlist. Now waiting."
  $session.process_events
  $session.wait_for { not $playlist.pending? } 
 
end


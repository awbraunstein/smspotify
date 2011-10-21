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
require 'net/http'
require 'json'
require 'cgi'

class Sp_search
  def self.get_sp_uris(term)
    @spotify_get_request = "http://ws.spotify.com/search/1/track.json?q="
    

    encoded_request = CGI.escape(term)

    request_url = @spotify_get_request+encoded_request
    data = Net::HTTP.get_response URI.parse(request_url)
    json_obj = JSON.parse(data.body)
    
    tracks = json_obj["tracks"]
    
    possible_tracks = []
    for i in (0..[3, tracks.length].min)
      track = tracks[i]
      track_name = track["name"]
      artist = track["artists"][0]["name"]
      sp_uri = track["href"]

      track_hash = {:name => track_name, :artist => artist, :uri => sp_uri}
      possible_tracks << track_hash
    end
    return possible_tracks
  end
  
end

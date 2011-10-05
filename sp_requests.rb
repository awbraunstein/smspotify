require 'hallon'
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

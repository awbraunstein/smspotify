# SMSpotify

## Allow users to text in suggestion for a spotify playlist.

People can text artist, song names, or album names, and they will be
given the 4 highest search results with the letters a,b,c,d. The user
will then be able to just text the letter back and the song will be
added to the playlist.

## Setup
   
1. Install libspotify

2. run

`bundle install`

3. create a config.rb file with

```ruby
ENV['HALLON_USERNAME'] = 'username'
ENV['HALLON_PASSWORD'] = 'password'
ENV['HALLON_APPKEY']   = File.expand_path('Path to appkey') 
```

## Usage

* Text name of song/artist and reply with letter associated with choice.

## Known Bugs

* libspotify will sometimes segfault

## Developers

* Andrew Braunstein

## Thanks

* This wouldn't have been possible without the work of Kim Burgestrand
  and his gem Hallon

* Spotify and their awesome service

* Twilio for their incredible API

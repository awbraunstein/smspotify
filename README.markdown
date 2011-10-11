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
3. Change `@playlist_uri` to whatever playlist you want to add songs to.
3. create a config.rb file with

```ruby
ENV['HALLON_USERNAME'] = 'username'
ENV['HALLON_PASSWORD'] = 'password'
ENV['HALLON_APPKEY']   = File.expand_path('Path to appkey') 
```

## Usage

* Text name of song/artist and reply with letter associated with choice.

## Future Features

* Multiple parties

* Get a list of songs in the playlist

* Administrator controls
 * Remove songs
 * Ban numbers
 * Start and stop party


## Known Bugs

* libspotify will sometimes segfault

## Developers

* Andrew Braunstein

## Thanks

* This wouldn't have been possible without the work of Kim Burgestrand
  and his gem Hallon

* Spotify and their awesome service

* Twilio for their incredible API

## Copyright

Copyright © 2011 Andrew Braunstein

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

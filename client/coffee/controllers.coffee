app = angular.module 'noTube'

class Video
	constructor: (obj)->
		@videoID = obj["media$group"]["yt$videoid"]["$t"]
		@link = "http://www.youtube.com/v/#{@videoID}"
		@duration = +(obj["media$group"]["media$content"][0]["duration"])
		@title = obj["title"]["$t"]
		@image = obj["media$group"]["media$thumbnail"][1]
		# console.log "#{@link}: #{@duration}, #{@videoID}"

class Playlist
	constructor: (obj)->
		@title = obj.feed.title
		@subtitle = obj.feed.subtitle
		@author = obj.feed.author
		@playlistID = obj.feed.playlistID
		@entry = obj.feed.entry
		@videos = (new Video(e) for e in @entry)

class ParserController
	constructor: (@$scope,@$http,@$log,@$sce)->
		@currentPlayingIndex = -1
		@player = videojs 'really-cool-video'
		@player.on 'ended', =>
			console.log 'video end'
			@playNextVideo()
		
	getPlaylist: (url)->
		url = @$scope.url
		# url = "https://www.youtube.com/watch?v=6Zfg3CCZMfk&list=RD6Zfg3CCZMfk#t=0"
		videoID = @getVideoID url
		playlistID = @getPlaylistID url
		console.log "#{videoID}, #{playlistID}"
		request = @$http.get "http://gdata.youtube.com/feeds/api/playlists/#{playlistID}?v=2&alt=json"
		request.then (result) =>
			@playlist = new Playlist(result.data)
			@$scope.playlist = @playlist
			@playNextVideo()
	
	playPreviousVideo: ->
		@playVideoWithIndex @currentPlayingIndex-1
	playNextVideo: ->
		@playVideoWithIndex @currentPlayingIndex+1
	playVideoWithIndex:(index)->
		video = new Video @playlist.entry[index]
		return unless video
		@currentPlayingIndex = index
		@playVideo video
	playVideo:(video)->
		request = @$http.get "/parse?url=#{encodeURIComponent(video.link)}"
		@$scope.busy = true
		request.then (result) =>
			@$scope.busy = false
			fileUrl = result.data.urls[0]
			console.log fileUrl
			return unless fileUrl
			@player.src {
				type: 'video/mp4',
				src: fileUrl
			}
			@player.play()

	getVideoID:(url)->
	    match = url.match /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
	    return match[2] if  match and match[2].length is 11
	getPlaylistID:(url)->
	    match = url.match /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|list=)([^#\&\?]*).*/
	    return match[2] if  match and match[2]

		
app.controller 'ParserController', ['$scope', '$http', '$log','$sce', ParserController]


class FacebookManager
	constructor: (@$scope,@$http,@Facebook) ->
		@$scope.$watch ()=>
			@Facebook.isReady()
		, (newVal)=>
			@$scope.facebookReady = true if newVal	
		@userIsConnected = false
		@$scope.$on 'Facebook:statusChange',@onStatusChanged
	login: ->
		return if @userIsConnected
		@Facebook.login (res)=>
			if res.status is 'connected'
				@userIsConnected = false
				@$scope.logged = true
				@me()
		,{scope:'public_profile, email'}

	onStatusChanged:(ev,data)=>
		console.log "FB Status: #{data.status}"
		status = data.status
		if status is 'connected'
			@userIsConnected = true
			@$scope.logged = true
			@me()
			# ...
	me: ->
		@Facebook.api '/me',(res)=>
			dict = {}
			dict.screenName = res.name
			dict.facebookID = res.id
			dict.gender = res.gender
			dict.email = res.email
			@loginToServer dict

	loginToServer: (userDict,callback)->
		request = @$http.post '/loginByFacebook', userDict
		request.then (res)=>
			@initUser res.data if res.status is 200
	
	initUser: (user)->
		@$scope.user = user if user

	logout: ->
		@Facebook.logout (res)=>
			@$scope.$apply ()=>
				@$scope.user = {}
				@$scope.logged = false
				@userIsConnected = false

class Video
	constructor: (obj)->
		@videoID = obj["media$group"]["yt$videoid"]["$t"]
		@link = "http://www.youtube.com/v/#{@videoID}"
		@duration = +(obj["media$group"]["media$content"][0]["duration"])
		@title = obj["title"]["$t"]
		@image = obj["media$group"]["media$thumbnail"][1]

		link = "https://www.youtube.com/watch?v=#{@videoID}"
		@mp3Url = "/download?url=#{encodeURIComponent(link)}"
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
	constructor: (@$scope,@$http,@$log,@$sce,@FacebookManager)->
		@currentPlayingIndex = -1
		@player = videojs 'really-cool-video'
		@player.on 'ended', =>
			console.log 'video end'
			@playNextVideo()
		
	getPlaylist: (url)->
		url = @$scope.url unless url
		# url = "https://www.youtube.com/watch?v=6Zfg3CCZMfk&list=RD6Zfg3CCZMfk#t=0"
		videoID = @getVideoID url
		playlistID = @getPlaylistID url
		console.log "#{videoID}, #{playlistID}"
		request = @$http.get "http://gdata.youtube.com/feeds/api/playlists/#{playlistID}?v=2&alt=json"
		request.then (res) =>
			@playlist = new Playlist(res.data)
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
		@getMp4Urls video, (urls)=>
			fileUrl = urls[0]
			console.log fileUrl
			return unless fileUrl
			@player.src {
				type: 'video/mp4',
				src: fileUrl
			}
			@player.play()
	getMp4Urls:(video,callback) ->
		request = @$http.get "/parse?url=#{encodeURIComponent(video.link)}"
		@$scope.busy = true
		request.then (result) =>
			@$scope.busy = false
			callback result.data.urls
	downloadMp4:(video)->
		@getMp4Urls video,(urls)=>
			window.downloadFile urls[0]
	getVideoID:(url)->
	    match = url.match /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
	    return match[2] if  match and match[2].length is 11
	getPlaylistID:(url)->
	    match = url.match /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|list=)([^#\&\?]*).*/
	    return match[2] if  match and match[2]

	# downloadMp3:(video)->
		# link = "https://www.youtube.com/watch?v=#{video.videoID}"
	# 	# request = @$http.get "/download?url=#{encodeURIComponent(link)}"
		# $.fileDownload "/download?url=#{encodeURIComponent(link)}"

app = angular.module 'noTube'
app.controller 'ParserController', ['$scope', '$http', '$log','$sce', ParserController]
app.controller 'FacebookManager',['$scope','$http','Facebook',FacebookManager]

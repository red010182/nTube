ytdl = require 'ytdl-core'
fs = require 'fs'
ffmpeg = require 'fluent-ffmpeg'

getUserJObject = (row)->
	facebookID: row["facebookID"],
	email: row["email"],
	lastLoginTime: row["lastLoginTime"],
	screenName: row["screenName"],
	avatar: row["avatar"],
	gender: row["gender"],
	userID: row["id"]

module.exports = 
	index:(req,res) ->
		res.render 'index'
	loginByFacebook:(req,res)->
		dict = {}
		dict["facebookID"] = req.body.facebookID
		dict["email"] = req.body.email
		now = Date.now() / 1000 | 0
		dict["lastLoginTime"] = now
		
		try
			pool.query 'SELECT * FROM User WHERE email=? AND facebookID=?',[dict.email,dict.facebookID],(err,rows)->
				throw err if err or (rows.length>1)
				
				# login
				if rows.length is 1
					res.json getUserJObject(rows[0])
					pool.query 'UPDATE User SET lastLoginTime=?',dict.lastLoginTime
				
				# register then login
				else
					dict["gender"] = req.body.gender
					dict["screenName"] = req.body.screenName
					# dict["avatar"] = req.body.fbImageUrl
					dict["registerTime"] = now
					pool.query 'INSERT INTO User SET ?',[dict],(err,result)->
						throw err if err

						# login
						pool.query 'SELECT * FROM User WHERE email=? AND facebookID=?',[dict.email,dict.facebookID],(err,rows)->
							throw err if err or (rows.length>1)
							res.json getUserJObject(rows[0])
			
					
		catch e
			console.log e
			res.status(400).end()

	parseUrl: (req,res)->
		console.log req.query.url
		spawn = require("child_process").spawn
		options = ['--skip-download','-g',req.query.url]
		parser = spawn "youtube-dl",options
		urls = []
		parser.stdout.on 'data', (data) ->
			url = data.toString()
			console.log url
			urls.push url
		parser.on 'close', (code) ->
			console.log "exit with code: #{code}"
			res.send {
				urls: urls
			}
	# for mp3
	download: (req,res)->
		url = req.query.url

		unless url
			console.log "get empty url, return default one"
			url = 'https://www.youtube.com/watch?v=HDqBCcOv_7U'
		
		res.set
			"Content-Type": "audio/mpeg",
			'Content-disposition', 'attachment; filename=a.mp3'
		stream = ytdl url, {quality:'lowest'}
		proc = ffmpeg(stream).toFormat('mp3')
		proc.setFfmpegPath('/usr/local/bin/ffmpeg')
		
		try
			proc.on 'start', (commandLine)->
					console.log('[command] ' + commandLine)
			.on 'progress', (progress) ->
				console.log('Processing: ' + progress.targetSize + ' bytes sent');
			.on 'end',	->
					console.log('Transcoding succeeded !');
			.on 'error', (err, stdout, stderr)->
				console.log "Error: #{err.message}"
			.pipe res,(retcode,err)->
				console.log('file has been converted succesfully');
				res.end('Video has been created');
		catch e
			console.log e
			res.end()
		# proc.output(res,{end:true}).run()
module.exports = 
	index:(req,res) ->
		res.render 'index'
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


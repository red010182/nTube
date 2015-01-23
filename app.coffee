express = require 'express'
router = require 'routes'
path = require 'path'
notifier = require 'node-notifier'
lessMiddleware = require 'less-middleware'
route = require './route/route'

port = 8888
app = express()
lessDir = __dirname + '/client/less'
coffeeDir = __dirname + '/client/coffee'
publicDir = __dirname + '/client/public'
bowerDir = __dirname + '/bower_components'

app.configure ()->
    app.set 'port', port
    app.set 'views', __dirname + '/views'
    app.set 'view engine', 'jade'
    app.use express.favicon()
    app.use express.logger('dev')
    app.use express.bodyParser()
    # app.use express.methodOverride()
    # app.use express.cookieParser('your secret here')
    # app.use express.session()
    # app.use app.router
    app.use lessMiddleware lessDir, 
        dest: publicDir,
        force: true,
        preprocess: 
            path: (pathname, req) ->
                return pathname.replace '/css/', '/'
        # without preprocess: get http://domain/css/app.css will look up lessDir/css/app.less
        # with preprocess: get http://domain/css/app.css will look up lessDir/app.less

    app.use require('connect-coffee-script')
        src: coffeeDir,
        dest: publicDir+'/js',
        prefix : '/js'
        force: true
        # without prefix: get http://domain/js/item.js will look up coffeeDir/js/item.coffee
        # with prefix: get http://domain/js/item.js will look up coffeeDir/item.coffee


    app.use express.static(publicDir)
    app.use '/bower_components',  express.static(bowerDir)


app.configure 'development', () ->
    app.use express.errorHandler()

app.get '/parse',route.parseUrl
app.get '/', route.index

server = app.listen port, ()->
    console.log 'Web Server Started at port: '+ port
    notifier.notify 
        'title': 'Web Server Start',
        'message': 'Port: ' + port, 
        icon: './ok.png',
        sound: true

# LiveReload
livereload = require('livereload').createServer
    exts: ['jade', 'less', 'coffee']
livereload.watch(coffeeDir);
livereload.watch(lessDir);
livereload.watch(__dirname+'/views');
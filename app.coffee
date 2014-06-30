http = require 'http'
express = require 'express'
expose = require 'express-expose'
socketio = require 'socket.io'
stylus = require 'stylus'
nib = require 'nib'
routes = require './lib/routes'

multipart = require 'connect-multiparty'
multipartMiddleware = multipart()

app = express()
server = http.createServer app
io = socketio.listen server
port = process.env.PORT or 5000

stylusCompile = (str, path) ->
	stylus(str).set('filename', path).set('compress', yes)
		.use(nib()).import 'nib'

app.configure ->
	app.set 'view engine', 'jade'
	app.set 'views', __dirname + '/views'
	app.use express.logger 'dev'
	app.use express.json()
	app.use express.urlencoded()
	app.use express.methodOverride()
	app.use stylus.middleware src: __dirname + '/public/styles', compile: stylusCompile
	app.use '/bower_components', express.static(__dirname + '/bower_components')
	app.use '/public', express.static __dirname + '/public'
	app.use app.router
	app.use (err, req, res, next) ->
	  res.render '500', error: err
	app.use express.errorHandler()
	
app.get '/', routes.app
app.post '/', routes.app
#app.post '/list', routes.getList
app.post '/save', routes.saveModel
app.post '/load', multipartMiddleware, routes.loadModel

io.on 'connection', (socket) ->
	socket.on 'connect-db', routes.connectDb
	socket.on 'get-reeng-data', routes.getReengData
	socket.on 'get-connections', routes.getConnections
	socket.on 'add-connection', routes.addConnection

server.listen port, -> 
	console.log 'Listening on port ' + port

# used for testing http requests
module.exports = app
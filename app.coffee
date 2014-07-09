http = require 'http'
express = require 'express'
expose = require 'express-expose'
socketio = require 'socket.io'
stylus = require 'stylus'
nib = require 'nib'
httpRoutes = require './lib/routes/http'
socketRoutes = require './lib/routes/socket'

multipart = require 'connect-multiparty'
multipartMiddleware = multipart()

app = express()
server = http.createServer app
io = socketio.listen server
port = process.env.PORT or 5000

stylusCompile = (str, path) ->
	stylus(str).set('filename', path).set('compress', yes)
		.use(nib()).import 'nib'

app.set 'view engine', 'jade'
app.set 'views', __dirname + '/views'
app.use express.logger 'dev'
app.use express.json()
app.use express.urlencoded()
#app.use express.methodOverride()
app.use stylus.middleware src: __dirname + '/public/styles', compile: stylusCompile
app.use '/bower_components', express.static(__dirname + '/bower_components')
app.use '/public', express.static __dirname + '/public'
app.use app.router
app.use (err, req, res, next) ->
  res.render '500', error: err
app.use express.errorHandler()
	
# App routers
app.get '/', httpRoutes.app
app.post '/', httpRoutes.app
#app.post '/list', httpRoutes.getList
app.post '/save', httpRoutes.saveModel
app.post '/load', multipartMiddleware, httpRoutes.loadModel
app.post '/export', httpRoutes.exportModel

io.on 'connection', (socket) ->
	socket.on 'connect-db', socketRoutes.connectDb
	socket.on 'get-reeng-data', socketRoutes.getReengData
	socket.on 'get-connections', socketRoutes.getConnections
	socket.on 'add-connection', socketRoutes.addConnection

server.listen port, -> 
	console.log 'Listening on port ' + port

# used for testing http requests
module.exports = app
http = require 'http'
express = require 'express'
expose = require 'express-expose'
socketio = require 'socket.io'
stylus = require 'stylus'
nib = require 'nib'
multipart = require 'connect-multiparty'

httpRoutes = require './lib/routes/http'
reengRoutes = require './lib/routes/socket/reeng'
versionRoutes = require './lib/routes/socket/versioning'

app = express()
server = http.createServer app
io = socketio.listen server
port = process.env.PORT or 5000

stylusCompile = (str, path) ->
  stylus(str).set('filename', path).set('compress', yes)
    .use(nib()).import 'nib'

app.set 'view engine', 'jade'
app.set 'views', "#{__dirname}/views"
app.use express.logger 'dev'
app.use express.favicon()
app.use express.json()
app.use express.urlencoded()
#app.use express.methodOverride()
app.use express.compress()
app.use stylus.middleware src: "#{__dirname}/public/styles", compile: stylusCompile
app.use '/bower_components', express.static "#{__dirname}/bower_components"
app.use '/public', express.static "#{__dirname}/public"
app.use app.router

if process.env.NODE_ENV is 'development' then app.use express.errorHandler()
else app.use (err, req, res, next) -> res.render '500', error: err

# App routers

app.get '/', httpRoutes.app
app.post '/', httpRoutes.app
#app.post '/list', httpRoutes.getList
app.post '/save/model', httpRoutes.saveModel
app.post '/save/sql', httpRoutes.saveSql
app.post '/load', multipart(), httpRoutes.loadModel
app.post '/export', httpRoutes.exportModel

io.on 'connection', (socket) ->
	socket.on 'connect-db', reengRoutes.connectDb
	socket.on 'get-reeng-data', reengRoutes.getReengData
	socket.on 'get-connections', reengRoutes.getConnections
	socket.on 'add-connection', reengRoutes.addConnection
	socket.on 'get-repos', versionRoutes.getRepos
	socket.on 'read-repo', versionRoutes.readRepo
	socket.on 'add-version', versionRoutes.addVersion
	socket.on 'get-version', versionRoutes.getVersion

server.listen port, ->
  console.log 'Listening on port ' + port

# used for testing http requests
module.exports = app
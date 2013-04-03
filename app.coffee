express = require 'express.io'
stylus = require 'stylus'
routes = require './src/routes'

# Main namespace on server part
global.Server = Server = {}

Server.app = app = express()
Server.databases = {}
Server.databases.dbs = {}
Server.databases.list = []
Server.databases.selected = null

app.http().io()

app.configure ->
	app.set 'view engine', 'jade'
	app.set 'views', __dirname + '/views'
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use stylus.middleware(src: __dirname + '/public')
	app.use express.static __dirname + '/public'
	app.use app.router
	app.use express.errorHandler()

app.get '/', routes.intro
app.post '/modeler', routes.app
app.get '/modeler', routes.app

port = 7076
app.listen port, -> console.log 'Listening on port ' + port 	
express = require 'express.io'
stylus = require 'stylus'
nib = require 'nib'
routes = require './src/routes'

# Main namespace on server part
global.Server = Server = {}

Server.app = app = express()
Server.databases = {}
Server.databases.dbs = {}
Server.databases.list = []
Server.databases.selected = null

app.http().io()

stylusCompile = (str, path) ->
	stylus(str).set('filename', path).set('compress', yes)
		.use(nib()).import 'nib'

app.configure ->
	app.set 'view engine', 'jade'
	app.set 'views', __dirname + '/views'
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use stylus.middleware src: __dirname + '/public', compile: stylusCompile
	app.use express.static __dirname + '/public'
	app.use app.router
	app.use express.errorHandler()

app.get '/', routes.intro
app.post '/modeler', routes.app
app.get '/modeler', routes.app

port = 7076
app.listen port, -> console.log 'Listening on port ' + port 	
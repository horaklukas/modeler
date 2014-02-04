express = require 'express'
expose = require 'express-expose'
stylus = require 'stylus'
nib = require 'nib'
routes = require './src/routes'

# Main namespace on server side
global.Server = Server = {}

Server.app = app = express()
Server.databases = {}
Server.databases.dbs = {}
Server.databases.list = []
Server.databases.selected = null

stylusCompile = (str, path) ->
	stylus(str).set('filename', path).set('compress', yes)
		.use(nib()).import 'nib'

app.configure ->
	app.set 'view engine', 'jade'
	app.set 'views', __dirname + '/views'
	app.use express.json()
	app.use express.urlencoded()
	app.use express.methodOverride()
	app.use stylus.middleware src: __dirname + '/public', compile: stylusCompile
	app.use '/bower_components', express.static(__dirname + '/bower_components')
	app.use '/public', express.static __dirname + '/public'
	app.use app.router
	app.use express.errorHandler()

app.get '/', routes.intro
app.post '/modeler', routes.app
app.get '/modeler', routes.app

port = process.env.PORT or 5000
app.listen port, -> console.log 'Listening on port ' + port 	
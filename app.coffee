express = require 'express.io'
stylus = require 'stylus'
routes = require './src/routes'

# Main namespace on server part
global.Server = Server = {}

Server.app = app = express()
Server.databases = {}
Server.databases.list = []

app.http().io()

app.configure ->
	app.set 'view engine', 'jade'
	app.set 'views', __dirname + '/views'
	app.use stylus.middleware(src: __dirname + '/public')
	app.use express.static __dirname + '/public'
	app.use app.router

app.get '/', routes.intro
app.get '/modeler', routes.app

port = proces.env.port or 5000
app.listen port, -> console.log 'Listening on port ' + port 	
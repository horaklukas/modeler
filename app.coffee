express = require 'express.io'
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
	app.use express.static __dirname + '/public'
	app.use app.router

app.get '/', routes.intro
app.get '/modeler', routes.app

port = 7076
app.listen port, -> console.log 'Listening on port ' + port 	
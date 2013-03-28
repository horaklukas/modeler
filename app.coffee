fs = require 'fs'
express = require('express.io')

app = express()
app.http().io()

dbDefs = []

app.configure ->
	app.set 'view engine', 'jade'
	app.set 'views', __dirname + '/views'
	app.use express.static __dirname + '/public'

app.get '/', (req, res) ->	
	unless dbDefs.length
		fs.readdir 'defs', (err, files) ->
			if err then console.log 'Error at reading defs dir!'
			else dbDefs = files; res.render 'intro', dbs:files
	else	
		res.render 'intro', dbs: dbDefs

app.get '/modeler', (req, res) ->
	res.render 'main'

port = 7076
app.listen port, -> console.log 'Listening on port ' + port 	
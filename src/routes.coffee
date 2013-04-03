fs = require 'fs'

routes =
	intro: (req, res) ->	
		unless Server.databases.list.length
			fs.readdir 'defs', (err, files) ->
				if err then console.log 'Error at reading defs dir!'
				else Server.databases.list = files; res.render 'intro', dbs:files
		else	
			res.render 'intro', dbs: Server.databases.list

	app: (req, res) ->
		# Intro not displayed (and dbs selected) yet
		unless Server.databases.selected
			if req.method is 'POST'
				# Selected dbs name not exist for not known reason, repeat select
				unless req.body.dbs then res.redirect '/'; return
				# Selected dbs know but its definition not loaded, load it 
				else unless Server.databases.dbs[req.body.dbs]
					Server.databases.selected = req.body.dbs
					Server.databases.dbs[req.body.dbs] = types: ['char','int','double']
			# Browser request, usually page refresh
			if req.method is 'GET' then res.redirect '/'; return
		
		options =
			title: Server.databases.selected
			types: Server.databases.dbs[Server.databases.selected].types

		res.render 'main', options

module.exports = routes
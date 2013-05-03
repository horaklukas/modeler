fs = require 'fs'

helping =
	loadDbDefinition: (name, cb) ->
		fs.readFile "defs/#{name}.json", 'utf8', (err, cont) ->
			if err? then console.error err; return

			cb JSON.parse cont

	renderWorkspace: (res) ->
		options =
			title: Server.databases.dbs[Server.databases.selected].name
			types: Server.databases.dbs[Server.databases.selected].types

		res.render 'main', options

routes =
	intro: (req, res) ->	
		unless Server.databases.list.length
			fs.readdir 'defs', (err, files) ->
				if err then console.log 'Error at reading defs dir!'
				else 
					Server.databases.list = files.map (file) -> file.replace '.json', ''
					res.render 'intro', dbs: Server.databases.list
		else	
			res.render 'intro', dbs: Server.databases.list

	app: (req, res) ->
		# Intro not displayed (and dbs selected) yet
		unless Server.databases.selected
			if req.method is 'POST'
				# Selected dbs name not exist for not known reason, repeat select
				unless req.body.dbs then res.redirect '/'; return
				else
					Server.databases.selected = req.body.dbs
					# Selected dbs know but its definition not loaded, load it 
					unless Server.databases.dbs[req.body.dbs]
						# Load definition, then render application
						helping.loadDbDefinition req.body.dbs, (def) ->
							Server.databases.dbs[req.body.dbs] = 
								name: def.name
								types: def.data.types

							helping.renderWorkspace res		

						return;

			# Browser request, usually page refresh
			if req.method is 'GET' then res.redirect '/'; return
		
		helping.renderWorkspace res

module.exports = routes
databases = require './dbs'

	#fs.readFile "defs/#{name}.json", 'utf8', (err, cont) ->
		#if err? then console.error err; return

		#cb JSON.parse cont

renderWorkspace = (res) ->
	selectedDb = databases.getDb databases.getSelected()
	
	res.expose {types: selectedDb.types}, 'DB'
	res.render 'main', title: selectedDb.name

exports.intro = (req, res) ->	
	databases.getList (err, list) ->
		if err? then console.error err 	
		else res.render 'intro', dbs: list

exports.app = (req, res) ->
	# Intro not displayed (and dbs selected) yet
	unless databases.getSelected()
		if req.method is 'POST'
			# Selected dbs name not exist for not known reason, repeat select
			unless req.body.dbs then res.redirect '/'; return
			else
				databases.setSelected req.body.dbs
				# Selected dbs know but its definition not loaded, load it 
				unless databases.getDb req.body.dbs
					# Load definition, then render application
					databases.loadDefinition req.body.dbs, (err) ->
						if err then return console.error err
						
						renderWorkspace res		

					return

		# Browser request, usually page refresh
		if req.method is 'GET' then res.redirect '/'; return
	
	renderWorkspace res
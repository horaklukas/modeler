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
		if err? then res.send 500, { error: err }
		else res.render 'intro', dbs: list

exports.app = (req, res) ->
	# intro displayed earlier and so database is selected
	if databases.getSelected() then return renderWorkspace res
	
	switch req.method
		when 'POST'
			dbId = req.body.dbs
			# Selected dbs name not exist for not known reason, repeat select
			unless dbId then return res.redirect '/'
			
			databases.setSelected dbId
			renderWorkspace res

	# Browser request, usually page refresh
		when 'GET' then return res.redirect '/'

exports.saveModel = (req, res) ->
	res.attachment "#{req.body.name ? 'unknown'}.json"

	res.setHeader 'Content-Type', 'application/json'
	res.end req.body.model, 'utf8'
fs = require 'fs'
databases = require './dbs'

exports.getList = (req, res) ->	
	databases.getList (err, list) ->
		if err? then res.send 500, err
		else res.json dbs: list

exports.app = (req, res) ->
	switch req.method
		# ajax request, setting of selected db
		when 'POST'
			dbId = req.body.db
			# selected dbs id not exist for not known reason
			unless dbId then return res.send 400, 'Id of db doesnt exist'
			
			databases.setSelected dbId
			res.json databases.getDb(dbId)

		# browser request, usually page refresh
		when 'GET'
			selectedId = databases.getSelected()
			if selectedId then selectedDb = databases.getDb selectedId
	
			if selectedDb
				res.expose {types: selectedDb?.types, dbs: null}, 'dmAssets'
				return res.render 'main', title: selectedDb?.name
			
			databases.getList (err, list) ->
				res.expose {dbs: list}, 'dmAssets'
				res.render 'main', title: 'Database not selected'

exports.saveModel = (req, res) ->
	res.attachment "#{req.body.name ? 'unknown'}.json"

	res.setHeader 'Content-Type', 'application/json'
	res.end req.body.model, 'utf8'

exports.loadModel = (req, res) ->
	fs.readFile req.files.modelfile.path, (err, content) ->
		if err? then res.send 500, err.code
		else
			try	res.json JSON.parse content
			catch e then res.send 500, 'Selected file isnt valid JSON'
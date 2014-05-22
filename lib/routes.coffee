fs = require 'fs'
databases = require './dbs'

###*
* POST request by ajax from select database dialog
###
exports.getList = (req, res) ->	
	databases.getList (err, list) ->
		if err? then res.send 500, err
		else res.json dbs: list

###*
* GET or POST request
###
exports.app = (req, res, next) ->
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
			exposeData = {}
			###
			selectedId = databases.getSelected()
			if selectedId then selectedDb = databases.getDb selectedId
	
			if selectedDb
				exposeData.name = selectedDb.name
				exposeData.version = selectedDb.version
				exposeData.types = selectedDb.types
			###
			databases.loadAllDefinitions (err, defs) ->
				if err then return next "Error at loading definitions #{err}"

				exposeData.dbs = defs

				res.expose exposeData, 'dmAssets'
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
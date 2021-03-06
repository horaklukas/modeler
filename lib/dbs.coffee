path = require 'path'
fs = require 'fs'
util = require 'util'

dbs = null
selected = null

defsDir = path.resolve __dirname, '..', 'defs'

module.exports = databases =
	getList: (cb) -> 
		responseCb = (err) ->
			if err and cb then cb err
			else cb null, (
				for id, info of dbs
					id: id, title: info.name + ' ' + info.version 
				)

		unless dbs? then databases.loadAllDefinitions(responseCb)
		else responseCb()

	getDb: (name) ->
		dbs?[name]
	
	setDb: (name, db) ->
		unless dbs? then dbs = {}
		dbs[name] = db

	setDbs: (newDbs) -> 
		dbs = newDbs

	getSelected: -> 
		selected

	setSelected: (name) ->
		selected = name

	loadDefinition: (name) ->
			# we can load it synchronously with require, because definition should 
			# be small and simple script
			def = require path.join defsDir, name

			if util.isArray def
				databases.setDb "#{name}-#{idx}", d for d, idx in def
			else 
				databases.setDb name, def

	loadAllDefinitions: (cb) ->
		fs.readdir defsDir, (err, files) ->
			if err then return cb 'Error at reading defs dir!'
			 
			dbsList = files.filter (file) -> /\.js$/.test file
			dbsList = dbsList.map (file) -> file.replace '.js', ''

			dbs = {}
			for dbName in dbsList
				try databases.loadDefinition dbName
				catch err then return cb err.message

			cb null, dbs
fs = require 'fs'
fspath = require 'path'
mkdirp = require 'mkdirp'
async = require 'async'
databases = require './dbs'
reverseEng = require './reverse-eng'
appVersion = require('../package').version

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

				page = 'main'
				page += '-devel' if @process.env.MODE is 'development'

				res.expose exposeData, 'dmAssets'
				res.render page, {title: 'Database not selected', version: appVersion}

###*
* POST request, invoke "save file" dialog for save model to JSON file
###
exports.saveModel = (req, res) ->
	res.attachment "#{req.body.name ? 'unknown'}.json"

	res.setHeader 'Content-Type', 'application/json'
	res.end req.body.model, 'utf8'

###*
* POST request that responses with content of selected file
###
exports.loadModel = (req, res) ->
	fs.readFile req.files.modelfile.path, (err, content) ->
		if err? then return res.send 500, err.code
		
		try	res.json JSON.parse content
		catch e then res.send 500, 'Selected file isnt valid JSON'

###*
* `connect-db` WebSocket event
*
* @param {string} type Type of database to get corresponding db interface
* @param {Object.<string,(string|number|boolen)>} connOptions
* @param {function(?err, ?Object.<string, string>=)} cb Function that gets err
*  as a first param if occured, or list of database schemas, if there is more
*  than one schema, or list of tables if only one schema is available at db
* @this {Socket}
###
exports.connectDb = (type, connOptions, cb) ->
	actualClient = reverseEng[type].getClient connOptions
	
	actualClient.connect (err) =>
		if err then return cb "Error at connecting do database: #{err}"

		@set 'actualClient', actualClient
		@set 'dbType', type		

		actualClient.query reverseEng[type].query.getSchemata(), (err, result) =>
			if err then return cb "Error at getting database schemata: #{err}"
			schemata = result.rows.map (row) -> row.schema_name

			if schemata.length is 1
				getTablesList.call this, schemata[0], cb
			else
				cb null, schemata: schemata
				@once 'schema-selected', getTablesList

###*
* @param {string} schema Name of database schema
* @param {function(?string, Array.<string>=)} mainCb
###
getTablesList = (schema, mainCb) ->
	@set 'actualSchema', schema
	
	actions = [
		(cb) => @get 'actualClient', cb
		(client, cb) => @get 'dbType', (err, type) -> cb null, client, type
		(client, type, cb) ->
			client.query reverseEng[type].query.getTablesList(schema), cb
	]

	async.waterfall actions, (err, result) ->
		if err then return mainCb "Error at getting tables"
		mainCb null, { tables: (result.rows.map (row) -> row.table_name) }

###*
* `get-reeng-data` Websocket event
*
* @param {Array.<string>} tables List of table names
* @param {function(?string, Array.<string>=)} mainCb
###
exports.getReengData = (tables, mainCb) ->
	dbClient = null
	dbType = null
	dbSchema = null
	actions = [
		(cb) => @get 'actualClient', (err, client) -> dbClient = client; cb()
		(cb) => @get 'dbType', (err, type) -> dbType = type; cb()
		(cb) => @get 'actualSchema', (err, schema) -> dbSchema = schema; cb()
		(cb) -> 
			dbClient.query reverseEng[dbType].query.getTableColumns(dbSchema, tables), (err, result) ->
				if err then return cb "Error at getting tables data: #{err}"
				cb null, result.rows
		(tablesData, cb) ->
			dbClient.query reverseEng[dbType].query.getRelations(dbSchema, tables), (err, result) ->
				if err then return cb "Error at getting relations data: #{err}"
				cb null, tablesData, result.rows
		(tablesData, relationsData, cb) ->
			dbClient.query reverseEng[dbType].query.getDbServerVersion(), (err, result) ->
				if err then return cb "Error at getting server version: #{err}"
				cb null, tablesData, relationsData, result.rows[0].version
	]

	async.waterfall actions, (err, tablesData, relationsData, dbVersion) =>
		@set 'actualClient', null
		@set 'dbType', null
		@set 'actualSchema', null
		dbClient.end()
		
		if err then return mainCb err
		
		mainCb null, { 
			columns: tablesData
			relations: relationsData
			db: "#{dbType}-#{dbVersion}" 
		}

###*
* @type {string}
###
connsFilePath = fspath.join	__dirname, '../data/connections.json'

###*
* `get-connections` Websocket event
*
* @param {function(?string, Array.<string>=)} cb
###
exports.getConnections = getConnections = (cb) ->
	options = 
		encoding: 'utf8'
		flag: 'a+' # new connections file is created if it doesnt exist

	mkdirp fspath.dirname(connsFilePath), (err) ->
		if err? then return cb "Error at reading connections files: #{err}"
		
		fs.readFile connsFilePath, options, (err, data) ->
			if err? then return cb "Error at reading connections file: #{err}"

			if not data? or data is '' then data = '{}'

			try cb null, JSON.parse(data)
			catch e then cb "Error at parsing connections file: #{e}"

###*
* `add-connections` Websocket event
*
* @param {string} name Connection name, should be unique (ensures client)
* @param {Object} conn Data needed for connection to db
* @param {function(?string=)} cb
###
exports.addConnection = (name, conn, cb) ->
	getConnections (err, connections) ->
		if err? then return cb err

		try 
			connections[name] = conn
			serializedConnections = JSON.stringify connections
		catch e
			cb "Error at saving connection: #{e}"

		fs.writeFile connsFilePath, serializedConnections, cb

dbs = {}
list = []
selected = null

module.exports =
	getList: -> list
	
	setList: (lst) ->
		list = lst

	getDb: (name) ->
		dbs[name]
	
	setDb: -> dbs

	getSelected: -> 
		selected

	setSelected: (name) ->
		selected = name

	loadDefinition: (name, cb) ->
		# we can load it synchronously with require, because definitio should be 
		# small and simple script
		try 
			dbs[name] = require "#{__dirname}/../defs/#{name}"
			cb null, dbs[name]
		catch err
			cb err
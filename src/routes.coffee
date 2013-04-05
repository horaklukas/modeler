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
		res.render 'main'

module.exports = routes
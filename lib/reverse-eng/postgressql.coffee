pg = require 'pg'
queries = require './queries'

client = new pg.Client({
	host: 'localhost'
	database: 'postgres'
	user: 'postgres'
	password: 'postgres'
	#port:
})

client.connect (err) ->
	if err then console.error "Error at connecting do database #{err}"

	client.query queries.getTableColumns('public'), (err, result) ->
		if err
			return console.error "Error at getting tables and columns: #{err}" 

		console.log 'Results'
		console.log result.rows
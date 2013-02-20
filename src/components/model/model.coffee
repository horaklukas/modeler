class Model
	constructor: (name) ->
		@tables = []
		@relations = []

	addTable: (canvas, x, y) ->
		new Table canvas, x, y, 100, 60

	addRelation: () ->	

if not window? then module.exports = Model
class Model
	constructor: (name) ->
		unless name then throw new Error 'Model name must be specified!'
		@tables = []
		@relations = []

	addTable: (canvas, x, y) ->
		@tables.push new Table canvas, "tab_#{@tables.length}" , x, y, 100, 60


	addRelation: (startTabId, endTabId) ->
		startTab = @getTabNumberId startTabId
		endTab = @getTabNumberId endTabId

		if startTab isnt false and endTab isnt false
			@relations.push new Relation
			

	getTabNumberId: (fullid) ->
		numberId = fullid.match /^tab_(\d+)$/

		if numberId? then Number(numberId[1]) else false

if not window? then module.exports = Model
class Model
	constructor: (name) ->
		unless name then throw new Error 'Model name must be specified!'
		@tables = []
		@relations = []

	addTable: (canvas, x, y) ->
		@tables.push new Table canvas, "tab_#{@tables.length}" , x, y, 100, 60

	addRelation: (canvas, startTabId, endTabId) ->
		startTab = @tables[@getTabNumberId startTabId]
		endTab = @tables[@getTabNumberId endTabId]

		if startTab isnt undefined and endTab isnt undefined
			relLen = @relations.push new Relation canvas, startTab, endTab
			startTab.addRelation @relations[relLen - 1]
			endTab.addRelation @relations[relLen - 1]
		else false

	getTabNumberId: (fullid) ->
		numberId = fullid.match /^tab_(\d+)$/

		if numberId? then Number(numberId[1]) else false

if not window? then module.exports = Model
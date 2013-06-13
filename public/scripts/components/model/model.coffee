class Model
	constructor: (name) ->
		unless name then throw new Error 'Model name must be specified!'
		@tables = []
		@relations = []

	###*
	* Add table to canvas and to model's list of tables
	*
  * @returns {string} id of new table
	###
	addTable: (canvas, x, y) =>
		tabId = "tab_#{@tables.length}"
		@tables.push new Table canvas, tabId, x, y, 100, 60
		return tabId

	###*
  * Pass new values from table dialog to table
  *
  * @param {string} id Identificator of table to edit
  * @param {string} name Name of table to set
  * @param {Object.<string, string|boolean>} columns
	###
	setTable: (id, name, columns) =>
		tab = @tables[@getTabNumberId id]

		tab.setName name
		tab.setColumns columns

	###*
	* Returns table object by table id
	*
	* @return {Table}
	###
	getTable: (id) ->
		@tables[@getTabNumberId id]

	###*
  * Add relation to canvas, the add relation to list of model's relations and
  * to both table list of related relations
	###
	addRelation: (canvas, startTabId, endTabId) =>
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
goog.provide 'dm.model.Model'

goog.require 'dm.model.Table'
goog.require 'dm.model.Relation'
goog.require 'goog.string'
goog.require 'goog.object'
goog.require 'goog.array'
goog.require 'goog.ui.IdGenerator'

class dm.model.Model
	constructor: (name) ->
		unless name then throw new Error 'Model name must be specified!'

		#@idgen_ = new goog.ui.IdGenerator()

		@name = name
		@tables_ = {}
		@relations_ = {}

		@relationsByTable = {}

	###*
	* Add model of the table to model's list of tables
	*
	* @param {dm.ui.Table} table
	###
	addTable: (table) =>
		@tables_[table.getId()] = table #.getModel()

	###*
	* Remove table from list of tables and all its reference to relations
	*
	* @param {string} id
	###
	removeTable: (id) =>
		goog.object.remove @tables_, id
		goog.object.remove @relationsByTable, id

	###*
	* @param {dm.ui.Relation} relation
	###
	addRelation: (relation) ->
		id = relation.getId()
		@relations_[id] = relation #.getModel()

		{parent, child} = relation.getModel().tables

		unless goog.object.containsKey @relationsByTable, parent
			goog.object.add @relationsByTable, parent, []

		unless goog.object.containsKey @relationsByTable, child
			goog.object.add @relationsByTable, child, []

		goog.array.insert @relationsByTable[parent], id
		goog.array.insert @relationsByTable[child], id

	###*
	* Remove relation from list of relations
	*
	* @param {string} id
	###
	removeRelation: (id) ->
		goog.object.remove @relations_, id

		goog.array.remove(rels, id) for tab, rels of @relationsByTable

	###*
	* Returns table ui by table id
  * @param {string} id
  * @return {(dm.ui.Table|null)}
	###
	getTableUiById: (id) ->
		@tables_[id] ? null

	###*
  * Returns relation ui by relation id
  * @param {string} id
  * @return {(dm.ui.Relation|null)}
	###
	getRelationUiById: (id) ->
		@relations_[id] ? null

	###*
	* Returns table model by table id
  * @param {string} id
  * @return {(dm.ui.Table|null)}
	###
	getTableById: (id) ->
		@tables_[id].getModel() ? null

	###*
  * Returns relation model by relation id
  * @param {string} id
  * @return {(dm.ui.Relation|null)}
	###
	getRelationById: (id) ->
		@relations_[id].getModel() ? null

	###*
  * @return {Object.<string, dm.model.Table>}
	###
	getTables: ->
		goog.object.map @tables_, (table) -> table.getModel()
		#(table.getModel() for id, table of @tables_)

	###*
  * @return {Object.<string, dm.model.Table>}
	###
	getRelations: ->
		goog.object.map @relations_, (relation) -> relation.getModel()
		#(relation.getModel() for id, relation of @relations_)

	###*
  * Maps tables by its names
  *
  * @return {Object.<string, dm.model.Table>}
	###
	getTablesByName: ->
		mappedTables = {}
		
		for id, table of @tables_
			model = table.getModel()
			mappedTables[model.getName()] = model 

		mappedTables

	###*
  * Maps tables by its names
  *
  * @return {Object.<string, dm.ui.Table>}
	###
	getTablesUiByName: ->
		mappedTables = {}
		
		for id, table of @tables_
			mappedTables[table.getModel().getName()] = table 

		mappedTables

	###*
  * @param {string} name
  * @return {(string|null)} id
	###
	getTableIdByName: (name) ->
		for id, table of @tables_ when table.getModel().getName() is name
			#console.log '' table.getModel().getName(), name
			return table.getId(); break

		return null

	###*
	* @param {string} tableId
  * @return {Object} List of table related relations
	###
	getRelationsByTable: (tableId) ->
		@relationsByTable[tableId] ? null

	###*
  * @return {Object} JSON representation of all data about model
	###
	toJSON: ->
		tablesData = (for id, table of @tables_
			{x, y} = table.getPosition()

			model: table.getModel().toJSON()
			pos: x: x, y: y
		)

		tableModels = @getTables()
		relationsData = []

		goog.object.forEach @getRelations(), (relModel) ->
			parent = tableModels[relModel.tables.parent].getName()
			child = tableModels[relModel.tables.child].getName()

			goog.array.insert relationsData, relModel.toJSON(parent, child)

		name: @name
		tables: tablesData
		relations: relationsData
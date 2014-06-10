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
  * @param {string} name
  * @param {string} id
	###
	getTableIdByName: (name) ->
		for id, table of @tables_ when table.getModel().getName() is name
			#console.log '' table.getModel().getName(), name
			return table.getId(); break

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
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

		model = relation.getModel()
		parentId = model.tables.parent.getId()
		childId = model.tables.child.getId()

		unless goog.object.containsKey @relationsByTable, parentId
			goog.object.add @relationsByTable, parentId, []

		unless goog.object.containsKey @relationsByTable, childId
			goog.object.add @relationsByTable, childId, []

		goog.array.insert @relationsByTable[parentId], id
		goog.array.insert @relationsByTable[childId], id

	###*
	* Returns table model by table id
  * @param {string} id
  * @return {dm.model.Table=}
	###
	getTableById: (id) ->
		@tables_[id]?.getModel() ? null

	###*
  * Returns relation model relation id
  * @param {string} id
  * @return {dm.model.Relation=}
	###
	getRelationById: (id) ->
		@relations_[id]?.getModel() ? null

	###*
  * @return {Array.<dm.model.Table>}
	###
	getTables: ->
		(table.getModel() for id, table of @tables_)

	###*
  * @return {Array.<dm.model.Table>}
	###
	getRelations: ->
		(relation.getModel() for id, relation of @relations_)

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
  * @return {Object} JSON representation of all data about model
	###
	toJSON: ->
		tablesData = (for id, table of @tables_
			{x, y} = table.getPosition()

			model: table.getModel().toJSON()
			pos: x: x, y: y
		)

		name: @name
		tables: tablesData
		relations: @getRelations().map (relModel) -> relModel.toJSON()
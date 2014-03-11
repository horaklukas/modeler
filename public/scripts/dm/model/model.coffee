goog.provide 'dm.model.Model'

goog.require 'dm.model.Table'
goog.require 'dm.model.Relation'
goog.require 'goog.string'
goog.require 'goog.ui.IdGenerator'

class dm.model.Model
	constructor: (name) ->
		unless name then throw new Error 'Model name must be specified!'

		#@idgen_ = new goog.ui.IdGenerator()

		@tables_ = {}
		@relations_ = {}

	###*
	* Add model of the table to model's list of tables
	*
	* @param {dm.ui.Table} table
	###
	addTable: (table) =>
		@tables_[table.getId()] = table.getModel()

	###*
  * Pass new values from table dialog to table
  *
  * @param {string} id Identificator of table to edit
  * @param {string} name Name of table to set
  * @param {Array.<Object.<string,*>>=} columns
	###
	###
	setTable: (id, name, columns) =>
		table = @getTableById id

		table.setName name

		if columns?
			table.setColumns columns
			table.render()
	###
	###*
	* @param {dm.ui.Relation} relation
	###
	addRelation: (relation) ->
		@relations_[relation.getId()] = relation.getModel()

	###
	setRelation: (id, ident, parentTab, childTab) ->
		rel = @getRelationById id

		rel.setIdentifying ident
		rel.setRelatedTables parentTab, childTab

		for column in parentTab.getColumns() when column.isPrimary() is true
			childTab.setColumn column.clone()

		childTab.render()
	###

	###*
	* Returns table model by table id
  * @param {string} id
  * @return {dm.model.Table=}
	###
	getTableById: (id) ->
		@tables_[id] ? null

	###*
  * Returns relation model relation id
  * @param {string} id
  * @return {dm.model.Relation=}
	###
	getRelationById: (id) ->
		@relations_[id] ? null

	###*
  * @return {Array.<dm.model.Table>}
	###
	getTables: ->
		@tables_

	###*
  * @return {Array.<dm.model.Table>}
	###
	getRelations: ->
		@relations_

	###*
  * Maps tables by its names
  *
  * @return {Object.<string, dm.model.Table>}
	###
	getTablesByName: ->
		mappedTables = {}
		
		mappedTables[table.getName()] = table for id, table of @tables_

		mappedTables
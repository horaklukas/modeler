goog.provide 'dm.model.Model'

goog.require 'dm.model.Table'
goog.require 'dm.model.Relation'
goog.require 'goog.string'
goog.require 'goog.ui.IdGenerator'

class dm.model.Model
	constructor: (name) ->
		unless name then throw new Error 'Model name must be specified!'

		@idgen_ = new goog.ui.IdGenerator()

		@tables_ = {}
		@relations_ = {}

	###*
	* Add table to canvas and to model's list of tables
	*
	* @param {Canvas} canvas Place where to create table
	* @param {number} x Horizontal position of table on canvas
	* @param {number} y Vertical position of table on canvas
  * @return {string} id of new table
	###
	addTable: (canvas, x, y, name) =>
		id = @idgen_.getNextUniqueId()
		table = new dm.model.Table canvas, id, x, y
		
		@tables_[id] = table
		
		return id

	###*
  * Pass new values from table dialog to table
  *
  * @param {string} id Identificator of table to edit
  * @param {string} name Name of table to set
  * @param {Array.<Object.<string,*>>=} columns
	###
	setTable: (id, name, columns) =>
		table = @getTableById id

		table.setName name

		if columns?
			table.setColumns columns
			table.render()

	###*
  * Add relation to canvas, the add relation to list of model's relations and
  * to both table list of related relations
	###
	addRelation: (canvas, startTabId, endTabId, ident) =>
		id = @idgen_.getNextUniqueId()

		startTab = @getTableById startTabId
		endTab = @getTableById endTabId

		if startTab? and endTab?
			newRelation = new dm.model.Relation canvas, id, startTab, endTab, ident
			@relations_[id] = newRelation
			
			startTab.addRelation newRelation
			endTab.addRelation newRelation
			
			return id
		else 
			return false

	setRelation: (id, ident, parentTab, childTab) ->
		rel = @getRelationById id

		rel.setIdentifying ident
		rel.setRelatedTables parentTab, childTab

		for column in parentTab.getColumns() when column.isPrimary() is true
			childTab.setColumn column.clone()

		childTab.render()

	###*
	* Returns table object by table id
  * @param {string} id
  * @return {dm.model.Table=}
	###
	getTableById: (id) ->
		@tables_[id] ? null

	###*
  * Returns relation object by relation id
  * @param {string} id
  * @return {dm.model.Relation=}
	###
	getRelationById: (id) ->
		@relations_[id] ? null

if not window? then module.exports = Model
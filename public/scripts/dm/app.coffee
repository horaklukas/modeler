goog.provide 'dm'

goog.require 'dm.model.Table'
goog.require 'dm.model.Relation'
goog.require 'dm.ui.Table'
goog.require 'dm.ui.Relation'

goog.require 'dm.dialogs.TableDialog'
goog.require 'dm.dialogs.RelationDialog'
goog.require 'dm.model.Model'
goog.require 'dm.ui.Canvas'
goog.require 'dm.ui.Toolbar'
goog.require 'dm.ui.tools.EventType'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.events'

canvasElement = goog.dom.getElement 'modelerCanvas'

tableDialog = new dm.dialogs.TableDialog()
relationDialog = new dm.dialogs.RelationDialog()

actualModel = new dm.model.Model 'Model1' 

canvas = new dm.ui.Canvas.getInstance()
canvas.render canvasElement

goog.events.listen canvas, dm.ui.Canvas.EventType.OBJECT_EDIT, (ev) -> 
	object = ev.target

	if object instanceof dm.ui.Relation then relationDialog.show yes, object
	else if object instanceof dm.ui.Table then tableDialog.show yes, object

mainToolbar = new dm.ui.Toolbar()
mainToolbar.renderBefore canvasElement

goog.events.listen mainToolbar, dm.ui.tools.EventType.CREATE, (ev) ->
	switch ev.objType
		when 'table'
			tab = new dm.ui.Table new dm.model.Table(), ev.data.x, ev.data.y
			canvas.addTable tab
			tableDialog.show true, tab
		when 'relation'
			rel = new dm.ui.Relation new dm.model.Relation(ev.data.identifying)
			rel.setRelatedTables ev.data.parent, ev.data.child 
			canvas.addRelation rel
			relationDialog.show true, rel

goog.events.listen mainToolbar, dm.ui.tools.EventType.GENERATE_SQL, (ev) ->
	generator = new dm.sqlgen.Sql92

	generator.generate(
		tables: actualModel.getTablesByName()
		relations: actualModel.getRelations()
	)

###*
* @param {dm.model.Table} model
* @param {number} x Horizontal coordinate of table position
* @param {string} y Vertical coordinate of table position
* @return {string} id of created table
###
dm.addTable = (model, x, y) ->
	tab = new dm.ui.Table model, x, y
	canvas.addTable tab
	actualModel.addTable tab
	tab.getId()

###*
* @param {dm.model.Relation} model
* @param {string} parentId Id of parent table
* @param {string} childId Id of child table
* @return {string} id of created relation
###
dm.addRelation = (model, parentId, childId) ->
	rel = new dm.ui.Relation model
	rel.setRelatedTables canvas.getChild(parentId), canvas.getChild(childId)
	canvas.addRelation rel
	actualModel.addRelation rel
	rel.getId()

#dm.getActualModel = ->
#	actualModel
#goog.events.listen tableDialog, dm.dialogs.TableDialog.EventType.CONFIRM, (ev) ->
#		dm.actualModel.setTable ev.tableId, ev.tableName, ev.tableColumns

#goog.events.listen relationDialog, dm.dialogs.RelationDialog.EventType.CONFIRM, (ev) ->
#		dm.actualModel.setRelation ev.relationId, ev.identifying, ev.parentTable, ev.childTable

#goog.exportSymbol 'dm.init', dm.init
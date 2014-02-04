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

appElement = goog.dom.getElement 'app'
canvasElement = goog.dom.getElement 'modelerCanvas'

tableDialog = new dm.dialogs.TableDialog()
relationDialog = new dm.dialogs.RelationDialog()

dm.actualModel = new dm.model.Model 'Model1' 

canvas = new dm.ui.Canvas.getInstance()
canvas.render canvasElement

mainToolbar = new dm.ui.Toolbar()
mainToolbar.renderBefore canvasElement

goog.events.listen canvas, dm.ui.Canvas.EventType.OBJECT_EDIT, (ev) -> 
	object = ev.target

	if object instanceof dm.ui.Relation then relationDialog.show yes, object
	else if object instanceof dm.ui.Table then tableDialog.show yes, object

goog.events.listen mainToolbar, dm.ui.tools.EventType.CREATE, (ev) ->
	switch ev.objType
		when 'table'
			tab = new dm.ui.Table new dm.model.Table(), ev.data.x, ev.data.y
			canvas.addTable tab
			tableDialog.show true, tab
		when 'relation'
			rel = new dm.ui.Relation(new dm.model.Relation(no))
			rel.setRelatedTables ev.data.parent, ev.data.child 
			canvas.addRelation rel
			relationDialog.show true, rel

#goog.events.listen tableDialog, dm.dialogs.TableDialog.EventType.CONFIRM, (ev) ->
#		dm.actualModel.setTable ev.tableId, ev.tableName, ev.tableColumns

#goog.events.listen relationDialog, dm.dialogs.RelationDialog.EventType.CONFIRM, (ev) ->
#		dm.actualModel.setRelation ev.relationId, ev.identifying, ev.parentTable, ev.childTable

#goog.exportSymbol 'dm.init', dm.init
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

	if object instanceof dm.ui.Relation then relationDialog.show true, object
	else if object instanceof dm.ui.Table then tableDialog.show true, object

#goog.events.listen canvas,
	#relationDialog.show 

goog.events.listen tableDialog, dm.dialogs.TableDialog.EventType.CONFIRM, (ev) ->
		dm.actualModel.setTable ev.tableId, ev.tableName, ev.tableColumns

goog.events.listen relationDialog, dm.dialogs.RelationDialog.EventType.CONFIRM, (ev) ->
		dm.actualModel.setRelation ev.relationId, ev.identifying, ev.parentTable, ev.childTable

goog.exportSymbol 'dm.init', dm.init
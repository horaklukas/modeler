goog.provide 'dm'
goog.provide 'dm.init'

goog.require 'dm.dialogs.TableDialog'
goog.require 'dm.model.Model'
goog.require 'dm.ui.Canvas'
goog.require 'dm.ui.ControlPanel'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.events'

dm.init = ->
	dm.$elem = goog.dom.getElement 'app'
	dm.tableDialog = new dm.dialogs.TableDialog DB.types
	dm.actualModel = new dm.model.Model 'Model1'
	 
	canvas = dm.ui.Canvas.getInstance()
	canvas.init 'modelerCanvas'
	dm.ui.ControlPanel.getInstance().init goog.dom.getElement 'controlPanel'

	goog.events.listen dm.tableDialog, dm.dialogs.TableDialog.EventType.CONFIRM, (ev) ->
			dm.actualModel.setTable ev.tableId, ev.tableName, ev.tableColumns

	# Some test objects
	tab0 = dm.actualModel.addTable canvas.html, 100, 75
	tabCols = [
		{ name: 'column_1', type: 'smallint', pk: true }
		{ name: 'column_2', type: 'character varcharying', pk: false }
		{ name: 'column_3', type: 'numeric', pk: false }
	]

	dm.actualModel.setTable tab0, 'table1', tabCols

	tab1 = dm.actualModel.addTable canvas.html, 500, 280
	dm.actualModel.setTable tab1, 'table2'

	tab2 = dm.actualModel.addTable canvas.html, 100, 280
	dm.actualModel.setTable tab2, 'table3'

	dm.actualModel.addRelation canvas.svg, tab0, tab1
	dm.actualModel.addRelation canvas.svg, tab0, tab2

goog.exportSymbol 'dm.init', dm.init
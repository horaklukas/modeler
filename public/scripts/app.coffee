goog.provide 'dm'

goog.require 'dm.dialogs.CreateTableDialog'
goog.require 'dm.components.model.Model'
goog.require 'dm.components.Canvas'
goog.require 'dm.components.ControlPanel'
goog.require 'goog.dom'

dm.init = ->
	dm.db = {}
	dm.$elem = goog.dom.getElement 'app'
	dm.dialogss = {}
	dm.dialogss.createTable = new dm.dialogs.CreateTableDialog DB.types
	dm.actualModel = new dm.components.model.Model('Model1')
	 
	dm.components.Canvas.init $('#modelerCanvas')
	dm.components.ControlPanel.init $('#controlPanel')

	dm.components.Canvas.on 'dblclick', '.table', ->
		tab = dm.actualModel.getTable this.id

		dm.dialogss.createTable.show this.id
		dm.dialogss.createTable.setValues tab.getName(), tab.getColumns() 

	dm.dialogss.createTable.onConfirm dm.actualModel.setTable

	# Some test objects
	tab0 = dm.actualModel.addTable dm.components.Canvas.obj, 100, 75
	tabCols = [
		{ name: 'column_1', type: 'smallint', pk: true }
		{ name: 'column_2', type: 'character varcharying', pk: false }
		{ name: 'column_3', type: 'numeric', pk: false }
	]

	dm.actualModel.setTable tab0, 'table1', tabCols

	tab1 = dm.actualModel.addTable dm.components.Canvas.obj, 500, 280
	dm.actualModel.setTable tab1, 'table2'

	tab2 = dm.actualModel.addTable dm.components.Canvas.obj, 100, 280
	dm.actualModel.setTable tab2, 'table3'

	dm.actualModel.addRelation dm.components.Canvas.self, tab0, tab1
	dm.actualModel.addRelation dm.components.Canvas.self, tab0, tab2
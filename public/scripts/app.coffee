App = {}
App.db = {}
App.$elem = $('#app')
App.dialogs = {}
App.dialogs.createTable = new createTableDialog DB.types
App.actualModel = new Model('Model1')
 
Canvas.init $('#modelerCanvas')
ControlPanel.init $('#controlPanel')

Canvas.on 'dblclick', '.table', ->
	tab = App.actualModel.getTable this.id

	App.dialogs.createTable.show this.id
	App.dialogs.createTable.setValues tab.getName(), tab.getColumns() 

App.dialogs.createTable.onConfirm App.actualModel.setTable

# Some test objects
tab0 = App.actualModel.addTable Canvas.obj, 100, 75, 'table1'
tab1 = App.actualModel.addTable Canvas.obj, 500, 280, 'table2'
tab2 = App.actualModel.addTable Canvas.obj, 100, 280, 'table3'
App.actualModel.addRelation Canvas.self, tab0, tab1
App.actualModel.addRelation Canvas.self, tab0, tab2
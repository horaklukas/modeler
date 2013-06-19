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

App.actualModel.addTable Canvas.obj, 100, 75
App.actualModel.addTable Canvas.obj, 500, 280
App.actualModel.addTable Canvas.obj, 100, 280
App.actualModel.addRelation Canvas.self, 'tab_0', 'tab_1'
App.actualModel.addRelation Canvas.self, 'tab_0', 'tab_2'
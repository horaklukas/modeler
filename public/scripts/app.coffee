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

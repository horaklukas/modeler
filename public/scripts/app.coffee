App = {}
App.db = {}
App.$elem = $('#app')
App.dialogs = {}
App.dialogs.createTable = new createTableDialog DB.types
App.actualModel = new Model('Model1')
 
Canvas.init $('#modelerCanvas')
ControlPanel.init $('#controlPanel')
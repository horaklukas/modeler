goog.provide 'dm'

goog.require 'dm.model.ModelManager'
goog.require 'dm.ui.Canvas'
goog.require 'dm.ui.Table.EventType'
goog.require 'dm.ui.Toolbar'
goog.require 'dm.ui.Toolbar.EventType'
goog.require 'dm.ui.SelectDbDialog'
goog.require 'dm.ui.TableDialog'
goog.require 'dm.ui.RelationDialog'
goog.require 'dm.ui.LoadModelDialog'
goog.require 'dm.ui.IntroDialog'
goog.require 'dm.ui.ReEngineeringDialog'
goog.require 'dm.ui.SimpleInputDialog'
goog.require 'dm.core.handlers'

goog.require 'goog.dom'
goog.require 'goog.events'


###*
* @type {Socket}
###
dm.socket = io.connect location.hostname

dm.socket.on 'disconnect', ->
  console.log 'Server disconnected at socket.io channel'

canvasElement = goog.dom.getElement 'modelerCanvas'
canvas = new dm.ui.Canvas.getInstance()
canvas.render canvasElement

toolbar = new dm.ui.Toolbar()
toolbar.renderBefore canvasElement

modelManager = new dm.model.ModelManager(canvas)

dm.core.init canvas, toolbar, modelManager

introDialog = React.renderComponent(
  dm.ui.IntroDialog(onSelect: dm.core.handlers.introActionSelected)
  goog.dom.getElement 'introDialog'
)

dm.core.registerDialog 'intro', introDialog

dm.core.getDialog('intro').show()

reengDialog = React.renderComponent(
  dm.ui.ReEngineeringDialog(
    connection: dm.socket, dbs: dmAssets.dbs
    onDataReceive: dm.core.handlers.reengRequest
  )
  goog.dom.getElement 'reengDialog'
)

dm.core.registerDialog 'reeng', reengDialog


selectDbDialog = React.renderComponent(
  dm.ui.SelectDbDialog(dbs: dmAssets.dbs, onSelect: dm.core.state.setActualRdbs)
  goog.dom.getElement 'selectDbDialog'
)

dm.core.registerDialog 'selectDb', selectDbDialog

tableDialog = React.renderComponent(
  dm.ui.TableDialog(types: null)
  goog.dom.getElement 'tableDialog'
)

dm.core.registerDialog 'table', tableDialog

relationDialog = React.renderComponent(
  dm.ui.RelationDialog()
  goog.dom.getElement 'relationDialog' 
)

dm.core.registerDialog 'relation', relationDialog

loadModelDialog = React.renderComponent(
  dm.ui.LoadModelDialog(onModelLoad: dm.core.handlers.modelLoad)
  goog.dom.getElement 'loadModelDialog' 
)

dm.core.registerDialog 'loadModel', loadModelDialog

inputDialog = React.renderComponent(
  dm.ui.SimpleInputDialog()
  goog.dom.getElement 'inputDialog' 
)

dm.core.registerDialog 'input', inputDialog

# handling events on components
goog.events.listen canvas, dm.ui.Table.EventType.MOVE, dm.core.handlers.moveObject

goog.events.listen canvas, dm.ui.Canvas.EventType.OBJECT_EDIT, dm.core.handlers.editObject

goog.events.listen canvas, dm.ui.Canvas.EventType.OBJECT_DELETE, dm.core.handlers.deleteObject

goog.events.listen toolbar, dm.ui.Toolbar.EventType.CREATE, dm.core.handlers.createObject

goog.events.listen toolbar, dm.ui.Toolbar.EventType.STATUS_CHANGE, dm.core.handlers.statusChange

goog.events.listen toolbar, dm.ui.Toolbar.EventType.GENERATE_SQL, dm.core.handlers.generateSqlRequest

goog.events.listen toolbar, dm.ui.Toolbar.EventType.SAVE_MODEL, dm.core.handlers.saveModelRequest

goog.events.listen toolbar, dm.ui.Toolbar.EventType.EXPORT_MODEL, dm.core.handlers.exportModelRequest

goog.events.listen toolbar, dm.ui.Toolbar.EventType.LOAD_MODEL, dm.core.getDialog('loadModel').show

goog.events.listen modelManager, dm.model.ModelManager.EventType.CHANGE, ->
    toolbar.setStatus modelManager.actualModel.name

goog.events.listen modelManager, dm.model.ModelManager.EventType.EDITED, ->
    dm.core.state.setSaved false

goog.dom.getWindow().onbeforeunload = dm.core.handlers.windowUnload

#goog.exportSymbol 'dm.init', dm.init
goog.provide 'dm'

goog.require 'dm.core.handlers'
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
goog.require 'dm.ui.InfoDialog'
goog.require 'dm.ui.ReEngineeringDialog'
goog.require 'dm.ui.SimpleInputDialog'
goog.require 'dm.ui.VersioningDialog'
goog.require 'dm.ui.tools.CreateTable'
goog.require 'dm.ui.tools.CreateRelation'
goog.require 'dm.ui.tools.SimpleCommandButton'

goog.require 'goog.ui.Toolbar'
goog.require 'goog.ui.ToolbarSeparator'
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

modelManager = new dm.model.ModelManager(canvas)

toolbar = new dm.ui.Toolbar()

toolbar.addChild new dm.ui.tools.CreateTable, true
toolbar.addChild new dm.ui.tools.CreateRelation(true), true
toolbar.addChild new dm.ui.tools.CreateRelation(false), true
toolbar.addChild new goog.ui.ToolbarSeparator(), true
toolbar.addChild new dm.ui.tools.SimpleCommandButton(
  'generate-sql', dm.ui.Toolbar.EventType.GENERATE_SQL, 'Generate SQL code'
), true
toolbar.addChild new goog.ui.ToolbarSeparator(), true
toolbar.addChild new dm.ui.tools.SimpleCommandButton(
  'save-model', dm.ui.Toolbar.EventType.SAVE_MODEL, 'Save model'
), true
toolbar.addChild new dm.ui.tools.SimpleCommandButton(
  'load-model', dm.ui.Toolbar.EventType.LOAD_MODEL, 'Load model'
), true
toolbar.addChild new goog.ui.ToolbarSeparator(), true
toolbar.addChild new dm.ui.tools.SimpleCommandButton(
  'export-model', dm.ui.Toolbar.EventType.EXPORT_MODEL, 'Export model'
), true
toolbar.addChild new dm.ui.tools.SimpleCommandButton(
  'version-model', dm.ui.Toolbar.EventType.VERSION_MODEL, 'Version model'
), true

toolbar.renderBefore canvasElement
dm.core.init canvas, toolbar, modelManager, dmAssets.dbs

dialogs =
  'intro': 
    componentName: 'IntroDialog'
    props: {onSelect: dm.core.handlers.introActionSelected}
  'reeng': 
    componentName: 'ReEngineeringDialog'
    props:
      connection: dm.socket, dbs: dmAssets.dbs
      onDataReceive: dm.core.handlers.reengRequest
    
  'selectDb':
    componentName: 'SelectDbDialog' 
    props: {dbs: dmAssets.dbs, onSelect: dm.core.state.setActualRdbs}
  'table':
    componentName: 'TableDialog'
    props: {types: null}
  'relation':
    componentName: 'RelationDialog' 
    props: {}
  'loadModel':
    componentName: 'LoadModelDialog' 
    props: {onModelLoad: dm.core.handlers.modelLoad}
  'input':
    componentName: 'SimpleInputDialog'
    props: {}
  'version':
    componentName: 'VersioningDialog'
    props: {}
  'info': 
    componentName: 'InfoDialog'
    props: {}

# create and register all neccessary dialogs
for type, spec of dialogs
  component = dm.ui[spec.componentName](spec.props)
  dialog = React.renderComponent component, goog.dom.getElement "#{type}Dialog"
  
  dm.core.registerDialog type, dialog

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

goog.events.listen toolbar, dm.ui.Toolbar.EventType.VERSION_MODEL, dm.core.handlers.versionModelRequest

goog.events.listen modelManager, dm.model.ModelManager.EventType.CHANGE, ->
    toolbar.setStatus modelManager.actualModel.name

goog.events.listen modelManager, dm.model.ModelManager.EventType.EDITED, ->
    dm.core.state.setSaved false

goog.events.listen modelManager, 'name-change', dm.core.handlers.tableNameChange

goog.dom.getWindow().onbeforeunload = dm.core.handlers.windowUnload

#goog.exportSymbol 'dm.init', dm.init

# display intro dialog when app start
dm.core.getDialog('intro').show()
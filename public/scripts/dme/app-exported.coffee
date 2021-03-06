goog.provide 'dme'

goog.require 'dm.model.ModelManager'
goog.require 'dm.ui.Table.EventType'
goog.require 'dm.ui.Canvas'
goog.require 'dm.ui.Toolbar'
goog.require 'dm.ui.Toolbar.EventType'
goog.require 'dm.ui.TableDialog'
goog.require 'dm.ui.RelationDialog'
goog.require 'dm.ui.SimpleInputDialog'
goog.require 'dm.ui.InfoDialog'
goog.require 'dm.ui.tools.CreateTable'
goog.require 'dm.ui.tools.CreateRelation'
goog.require 'dm.ui.tools.SimpleCommandButton'
goog.require 'dm.core'
goog.require 'dm.core.handlers'
goog.require 'dme.core'
goog.require 'dme.core.handlers'

goog.require 'goog.ui.Toolbar'
goog.require 'goog.ui.ToolbarSeparator'
goog.require 'goog.dom'
goog.require 'goog.events'

goog.exportProperty dm.ui, 'InfoDialog', dm.ui.InfoDialog
goog.exportProperty dm.ui, 'TableDialog', dm.ui.TableDialog
goog.exportProperty dm.ui, 'RelationDialog', dm.ui.RelationDialog
goog.exportProperty dm.ui, 'SimpleInputDialog', dm.ui.SimpleInputDialog

canvasElement = goog.dom.getElement 'modelerCanvas'
canvas = new dm.ui.Canvas.getInstance()
canvas.render canvasElement

toolbar = new dm.ui.Toolbar()

modelManager = new dm.model.ModelManager(canvas)

toolbar.addChild new dm.ui.tools.CreateTable, true
toolbar.addChild new dm.ui.tools.CreateRelation(true), true
toolbar.addChild new dm.ui.tools.CreateRelation(false), true
toolbar.addChild new goog.ui.ToolbarSeparator(), true
toolbar.addChild new dm.ui.tools.SimpleCommandButton(
  'generate-sql', dm.ui.Toolbar.EventType.GENERATE_SQL, 'Generate SQL code'
), true
toolbar.addChild new dm.ui.tools.SimpleCommandButton(
  'save-model', dm.ui.Toolbar.EventType.SAVE_MODEL, 'Save model'
), true
toolbar.addChild new dm.ui.tools.SimpleCommandButton(
  'load-model', dm.ui.Toolbar.EventType.LOAD_MODEL, 'Load model'
), true
toolbar.addChild new goog.ui.ToolbarSeparator(), true

toolbar.renderBefore canvasElement

defs = {}
defs[dmDefault.dbId] = dmDefault.db

dm.core.init canvas, toolbar, modelManager, defs
dme.core.init dmDefault.id

dialogs =    
  'table':
    componentName: 'TableDialog'
    props: {types: null}
  'relation':
    componentName: 'RelationDialog' 
    props: {}
  'info': 
    componentName: 'InfoDialog'
    props: {}
  'input':
    componentName: 'SimpleInputDialog'
    props: {}

# create and register all neccessary dialogs
for type, spec of dialogs
  component = dm.ui[spec.componentName](spec.props)
  dialog = React.renderComponent component, goog.dom.getElement "#{type}Dialog"
  
  dm.core.registerDialog type, dialog

# handling events on components
goog.events.listen canvas, dm.ui.Table.EventType.MOVE,dm.core.handlers.moveObject

goog.events.listen canvas, dm.ui.Canvas.EventType.OBJECT_EDIT, dm.core.handlers.editObject

goog.events.listen canvas, dm.ui.Canvas.EventType.OBJECT_DELETE, dm.core.handlers.deleteObject

goog.events.listen toolbar, dm.ui.Toolbar.EventType.CREATE,dm.core.handlers.createObject

goog.events.listen toolbar, dm.ui.Toolbar.EventType.STATUS_CHANGE, dm.core.handlers.statusChange

goog.events.listen toolbar, dm.ui.Toolbar.EventType.GENERATE_SQL, dm.core.handlers.generateSqlRequest

goog.events.listen toolbar, dm.ui.Toolbar.EventType.SAVE_MODEL, dme.core.handlers.saveRequest

goog.events.listen toolbar, dm.ui.Toolbar.EventType.LOAD_MODEL, dme.core.handlers.loadRequest

goog.events.listen modelManager, dm.model.ModelManager.EventType.CHANGE, ->
    toolbar.setStatus modelManager.actualModel.name

goog.events.listen modelManager, dm.model.ModelManager.EventType.EDITED, ->
    dm.core.state.setSaved false

goog.dom.getWindow().onbeforeunload = dm.core.handlers.windowUnload

dm.core.state.setActualRdbs dmDefault.dbId

modelManager.createActualFromLoaded(
  dmDefault.model.name, dmDefault.model.tables, dmDefault.model.relations
)
dm.core.state.setSaved true

#goog.exportSymbol 'dm.init', dm.init
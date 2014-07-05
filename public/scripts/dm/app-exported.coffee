goog.provide 'dme'

goog.require 'dm.model.Table'
goog.require 'dm.model.Relation'
goog.require 'dm.model.ModelManager'
goog.require 'dm.ui.Table'
goog.require 'dm.ui.Relation'
goog.require 'dm.ui.Canvas'
goog.require 'dm.ui.Toolbar'
goog.require 'dm.ui.Toolbar.EventType'
goog.require 'dm.ui.TableDialog'
goog.require 'dm.ui.RelationDialog'
goog.require 'dm.ui.SimpleInputDialog'
goog.require 'dm.sqlgen.list'
goog.require 'goog.dom'
goog.require 'goog.events'
goog.require 'goog.storage.Storage'
goog.require 'goog.storage.mechanism.HTML5LocalStorage'

###*
* @type {Object}
###
dme.dbDef = dmDefault.db

###*
* If last version of actual model is saved
* @type {boolean}
###
dme.saved = true

###*
* @type {string}
###
dme.state = ''

###*
* Id of exported app for identification at local storage
* @type {string}
###
dme.ID = dmDefault.id 

canvasElement = goog.dom.getElement 'modelerCanvas'
canvas = new dm.ui.Canvas.getInstance()
canvas.render canvasElement

toolbar = new dm.ui.Toolbar()
toolbar.renderBefore canvasElement

modelManager = new dm.model.ModelManager(canvas)

toolbar.setStatus(
  dmDefault.model.name, "#{dme.dbDef.name} #{dme.dbDef.version}", true
)

modelManager.createActualFromLoaded(
  dmDefault.model.name, dmDefault.model.tables, dmDefault.model.relations
)

dme.storage = null
mechanism = new goog.storage.mechanism.HTML5LocalStorage

dme.storage = new goog.storage.Storage(mechanism) if mechanism.isAvailable()

###*
* @param {string} db Id of db to set as actual
###
###
dm.setActualRdbs = (db) ->
  dbDef = dmDefault.dbs[db]

  console.error 'Selected database isnt defined' if not dbDef

  dm.actualRdbs = db
  tableDialog.setProps types: dbDef.types

  goog.dom.setTextContent(
    goog.dom.getElementsByTagNameAndClass('title')[0], dbDef.name
  )
  toolbar.setStatus null, "#{dbDef.name} #{dbDef.version}"

selectDbDialog = React.renderComponent(
  dm.ui.SelectDbDialog(dbs: dmDefault.dbs, onSelect: dm.setActualRdbs)
  goog.dom.getElement 'selectDbDialog'
)
###
tableDialog = React.renderComponent(
  dm.ui.TableDialog(types: dme.dbDef.types)
  goog.dom.getElement 'tableDialog'
)

relationDialog = React.renderComponent(
  dm.ui.RelationDialog()
  goog.dom.getElement 'relationDialog' 
)

###*
* @param {boolean} saved
###
dme.setModelSaveStatus = (saved) ->
  dme.saved = saved
  toolbar.setStatus null, null, saved

###*
* @param {Object} json JSON representation of model
###
dme.handleModelLoad = (json) ->
  modelManager.createActualFromLoaded json.name, json.tables, json.relations
  
  # set model's db as a actual
  #dm.setActualRdbs json.db
  dme.setModelSaveStatus true

###
loadModelDialog = React.renderComponent(
  dm.ui.LoadModelDialog(onModelLoad: dm.handleModelLoad)
  goog.dom.getElement 'loadModelDialog' 
)
###

inputDialog = React.renderComponent(
  dm.ui.SimpleInputDialog()
  goog.dom.getElement 'inputDialog' 
)

# handling events on components
goog.events.listen canvas, dm.ui.Table.EventType.MOVE, (e) ->
  relationsIds = modelManager.actualModel.getRelationsByTable(e.target.getId()) ? []

  for relId in relationsIds
    relation = modelManager.actualModel.getRelationUiById relId 
    {parent, child} = relation.getModel().tables

    relation.recountPosition(
      canvas.getChild(parent).getElement()
      canvas.getChild(child).getElement()
    )

goog.events.listen canvas, dm.ui.Canvas.EventType.OBJECT_EDIT, ({target}) -> 
  model = target.getModel()

  if target instanceof dm.ui.Relation
    {parent, child} = model.tables
    tables = 
      parent: 
        id: parent
        name: modelManager.actualModel.getTableById(parent).getName()
      child: 
        id: child
        name: modelManager.actualModel.getTableById(child).getName()

    relationDialog.show model, tables
  else if target instanceof dm.ui.Table
    tableDialog.show model

goog.events.listen canvas, dm.ui.Canvas.EventType.OBJECT_DELETE, ({target}) =>
  model = target.getModel()

  if confirm("You want to delete #{model.getName()}'. Are you sure?") is true
    
    if target instanceof dm.ui.Relation then modelManager.deleteRelation target
    else if target instanceof dm.ui.Table
      relatedRelations = modelManager.actualModel.getRelationsByTable(
        target.getId()
      )

      for relId in (relatedRelations ? [])
        modelManager.deleteRelation(
          modelManager.actualModel.getRelationUiById relId
        )

      modelManager.deleteTable target

goog.events.listen toolbar, dm.ui.Toolbar.EventType.CREATE, (ev) ->
  switch ev.objType
    when 'table'
      model = new dm.model.Table()
      modelManager.addTable model, ev.data.x, ev.data.y
      tableDialog.show model
    when 'relation'
      {parent, child, identifying} = ev.data
      #rel.setRelatedTables parent.getModel(), child.getModel() 

      model = new dm.model.Relation identifying, parent, child
      tables = 
        parent: 
          id: parent
          name: modelManager.actualModel.getTableById(parent).getName()
        child: 
          id: child
          name: modelManager.actualModel.getTableById(child).getName()

      modelManager.addRelation model
      relationDialog.show model, tables

goog.events.listen toolbar, dm.ui.Toolbar.EventType.STATUS_CHANGE, (ev) ->
  inputDialog.show(
    modelManager.actualModel.name
    'Type and confirm model name'
    modelManager.changeActualModelName
  )

goog.events.listen toolbar, dm.ui.Toolbar.EventType.GENERATE_SQL, (ev) ->
  actualDbType = dme.actualRdbs.id.match(/^([a-zA-Z]*)\-/)?[1]
  generator = dm.sqlgen.list[actualDbType ? 'sql']

  generator.generate(
    tables: modelManager.actualModel.getTables()
    relations: modelManager.actualModel.getRelations()
  )

goog.events.listen toolbar, dm.ui.Toolbar.EventType.SAVE_MODEL, (ev) ->
  return console.warn('Storage mechanism isnt available') unless dme.storage?
  
  dme.storage.set dme.ID, modelManager.actualModel.toJSON()
  dme.setModelSaveStatus true

goog.events.listen toolbar, dm.ui.Toolbar.EventType.LOAD_MODEL, (ev) ->
  return console.warn('Storage mechanism isnt available') unless dme.storage?
  
  json = dme.storage.get dme.ID
  modelManager.createActualFromLoaded json.name, json.tables, json.relations
  dme.setModelSaveStatus true

goog.events.listen modelManager, dm.model.ModelManager.EventType.CHANGE, ->
    toolbar.setStatus modelManager.actualModel.name

goog.events.listen modelManager, dm.model.ModelManager.EventType.EDITED, ->
    dme.setModelSaveStatus false

goog.dom.getWindow().onbeforeunload = (ev) ->
  # when saving model dont show dialog
  if dme.state is 'saving'
    dm.state = ''
    return 

  if not dme.saved
    return "Model #{modelManager.actualModel.name} isnt saved, really exit?"

  ###
  msg = 'Really unload?'
  {IE, FIREFOX} = goog.userAgent.product

  if IE or FIREFOX then ev.getBrowserEvent().returnValue = msg
  else msg
  ###

#goog.exportSymbol 'dm.init', dm.init
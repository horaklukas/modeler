goog.provide 'dm'

goog.require 'dm.model.Table'
goog.require 'dm.model.Relation'
goog.require 'dm.model.ModelManager'
goog.require 'dm.ui.Table'
goog.require 'dm.ui.Relation'
goog.require 'dm.ui.Canvas'
goog.require 'dm.ui.Toolbar'
goog.require 'dm.ui.Toolbar.EventType'
goog.require 'dm.ui.SelectDbDialog'
goog.require 'dm.ui.TableDialog'
goog.require 'dm.ui.RelationDialog'
goog.require 'dm.ui.LoadModelDialog'
goog.require 'dm.ui.IntroDialog'
goog.require 'dm.ui.ReEngineeringDialog'
goog.require 'dm.ui.SimpleInputDialog'
goog.require 'dm.sqlgen.Sql92'

goog.require 'goog.dom'
goog.require 'goog.events'
goog.require 'goog.userAgent.product'

###*
* @type {string}
###
dm.actualRdbs = null

###*
* If last version of actual model is saved
* @type {boolean}
###
dm.saved = true

###*
* @type {string}
###
dm.state = ''

###*
* @type {Socket}
###
dm.socket = io.connect 'http://localhost'

dm.socket.on 'disconnect', ->
  console.log 'Server disconnected at socket.io channel'

canvasElement = goog.dom.getElement 'modelerCanvas'
canvas = new dm.ui.Canvas.getInstance()
canvas.render canvasElement

toolbar = new dm.ui.Toolbar()
toolbar.renderBefore canvasElement

modelManager = new dm.model.ModelManager(canvas)

###*
* @param {boolean} saved
###
dm.setModelSaveStatus = (saved) ->
  dm.saved = saved
  toolbar.setStatus null, null, saved

dm.handleNewModel = (db) ->
  dm.setActualRdbs db
  inputDialog.show(
    'NewModel', 'Type name of new model', modelManager.bakupOldCreateNewActual
  )
  dm.setModelSaveStatus true

###*
* @param {string} action Id of action selected at intro dialog
###
dm.handleIntroAction = (action) ->
  switch action
    when 'new' then selectDbDialog.show(dm.handleNewModel)
    when 'load' then loadModelDialog.show()
    #when 'byversion' then ''
    when 'fromdb' then reengDialog.show()
    else return

  introDialog.hide()

introDialog = React.renderComponent(
  dm.ui.IntroDialog(onSelect: dm.handleIntroAction)
  goog.dom.getElement 'introDialog'
) 

introDialog.show()

###*
* @param {Object.<string, object>} object containing keys `tables` and 
*  `relations`
###
dm.handleReeng = (data) ->
  name = 'Reengineered model' # @TODO replace this with mode input dialog
  modelManager.createActualFromCatalogData name, data.columns, data.relations

  # set model's db as a actual with replaced dots at version string
  dm.setActualRdbs data.db.replace '.', '-'
  dm.setModelSaveStatus true

reengDialog = React.renderComponent(
  dm.ui.ReEngineeringDialog(
    connection: dm.socket, dbs: dmAssets.dbs, onDataReceive: dm.handleReeng
  )
  goog.dom.getElement 'reengDialog'
)

###*
* @param {string} db Id of db to set as actual
###
dm.setActualRdbs = (db) ->
  dbDef = dmAssets.dbs[db]

  console.error 'Selected database isnt defined' if not dbDef

  dm.actualRdbs = db
  tableDialog.setProps types: dbDef.types

  goog.dom.setTextContent(
    goog.dom.getElementsByTagNameAndClass('title')[0], dbDef.name
  )
  toolbar.setStatus null, "#{dbDef.name} #{dbDef.version}"

selectDbDialog = React.renderComponent(
  dm.ui.SelectDbDialog(dbs: dmAssets.dbs, onSelect: dm.setActualRdbs)
  goog.dom.getElement 'selectDbDialog'
)

tableDialog = React.renderComponent(
  dm.ui.TableDialog(types: null)
  goog.dom.getElement 'tableDialog'
)

relationDialog = React.renderComponent(
  dm.ui.RelationDialog()
  goog.dom.getElement 'relationDialog' 
)

###*
* @param {Object} json JSON representation of model
###
dm.handleModelLoad = (json) ->
  modelManager.createActualFromLoaded json.name, json.tables, json.relations
  
  # set model's db as a actual
  dm.setActualRdbs json.db
  dm.setModelSaveStatus true

loadModelDialog = React.renderComponent(
  dm.ui.LoadModelDialog(onModelLoad: dm.handleModelLoad)
  goog.dom.getElement 'loadModelDialog' 
)

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

goog.events.listen canvas, dm.ui.Canvas.EventType.OBJECT_EDIT, (ev) -> 
  object = ev.target
  model = object.getModel()

  if object instanceof dm.ui.Relation
    {parent, child} = model.tables
    tables = 
      parent: 
        id: parent
        name: modelManager.actualModel.getTableById(parent).getName()
      child: 
        id: child
        name: modelManager.actualModel.getTableById(child).getName()

    relationDialog.show model, tables
  else if object instanceof dm.ui.Table
    tableDialog.show model

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

goog.events.listen toolbar, dm.ui.Toolbar.EventType.GENERATE_SQL, (ev) ->
  generator = new dm.sqlgen.Sql92

  generator.generate(
    tables: modelManager.actualModel.getTables()
    relations: modelManager.actualModel.getRelations()
  )

goog.events.listen toolbar, dm.ui.Toolbar.EventType.SAVE_MODEL, (ev) ->
  name = modelManager.actualModel.name.toLowerCase()
  model = modelManager.actualModel.toJSON()
  model.db = dm.actualRdbs

  model = JSON.stringify model

  form = goog.dom.createDom(
    'form', {action: '/save', method: 'POST'}
    goog.dom.createDom 'input', {type: 'hidden', name: 'name', value: name }
    goog.dom.createDom 'input', {type: 'hidden', name: 'model', value: model }
  )

  dm.state = 'saving'
  form.submit()

goog.events.listen toolbar, dm.ui.Toolbar.EventType.LOAD_MODEL, loadModelDialog.show

goog.events.listen modelManager, dm.model.ModelManager.EventType.CHANGE, ->
    toolbar.setStatus modelManager.actualModel.name

goog.events.listen modelManager, dm.model.ModelManager.EventType.EDITED, ->
    dm.setModelSaveStatus false

goog.dom.getWindow().onbeforeunload = (ev) ->
  # when saving model dont show dialog
  if dm.state is 'saving'
    dm.state = ''
    return 

  if not dm.saved
    return "Model #{modelManager.actualModel.name} isnt saved, really exit?"

  ###
  msg = 'Really unload?'
  {IE, FIREFOX} = goog.userAgent.product

  if IE or FIREFOX then ev.getBrowserEvent().returnValue = msg
  else msg
  ###

#goog.exportSymbol 'dm.init', dm.init

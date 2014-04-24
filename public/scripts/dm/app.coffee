goog.provide 'dm'

goog.require 'dm.model.Table'
goog.require 'dm.model.Relation'
goog.require 'dm.ui.Table'
goog.require 'dm.ui.Relation'

goog.require 'dm.ui.SelectDbDialog'
goog.require 'dm.ui.TableDialog'
goog.require 'dm.dialogs.RelationDialog'
goog.require 'dm.dialogs.LoadModelDialog'
goog.require 'dm.model.Model'
goog.require 'dm.model.Table.index'
goog.require 'dm.ui.Canvas'
goog.require 'dm.ui.Toolbar'
goog.require 'dm.ui.Toolbar.EventType'
goog.require 'dm.sqlgen.Sql92'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.events'

tableDialog = React.renderComponent(
  dm.ui.TableDialog types: dmAssets.types
  goog.dom.getElement 'tableDialog'
)

relationDialog = new dm.dialogs.RelationDialog()
loadModelDialog = new dm.dialogs.LoadModelDialog()

actualModel = new dm.model.Model 'Model1' 

canvasElement = goog.dom.getElement 'modelerCanvas'
canvas = new dm.ui.Canvas.getInstance()
canvas.render canvasElement

mainToolbar = new dm.ui.Toolbar()
mainToolbar.renderBefore canvasElement

if dmAssets.dbs?
  selectDbDialog = React.renderComponent(
    dm.ui.SelectDbDialog dbs: dmAssets.dbs
    goog.dom.getElement 'selectDbDialog'
  )

  selectDbDialog.setState visible: true

  selectDbDialog.setProps onDatabaseSelect: (db) ->
    dmAssets.types = db.types
    tableDialog.setProps types: db.types
    # fill <title> with database name
    goog.dom.setTextContent(
      goog.dom.getElementsByTagNameAndClass('title')[0], db.name
    )

    mainToolbar.setStatus "#{db.name} #{db.version}"
else
  mainToolbar.setStatus "#{dmAssets.name} #{dmAssets.version}"

goog.events.listen canvas, dm.ui.Canvas.EventType.OBJECT_EDIT, (ev) -> 
  object = ev.target
  model = object.getModel()

  if object instanceof dm.ui.Relation then relationDialog.show yes, object
  else if object instanceof dm.ui.Table
    tableDialog.show model

goog.events.listen mainToolbar, dm.ui.Toolbar.EventType.CREATE, (ev) ->
  switch ev.objType
    when 'table'
      model = new dm.model.Table()
      tab = new dm.ui.Table model, ev.data.x, ev.data.y
      canvas.addTable tab
      tableDialog.show model
    when 'relation'
      rel = new dm.ui.Relation new dm.model.Relation(ev.data.identifying)
      rel.setRelatedTables ev.data.parent, ev.data.child 
      canvas.addRelation rel
      relationDialog.show true, rel

goog.events.listen mainToolbar, dm.ui.Toolbar.EventType.GENERATE_SQL, (ev) ->
  generator = new dm.sqlgen.Sql92

  generator.generate(
    tables: actualModel.getTablesByName()
    relations: actualModel.getRelations()
  )

goog.events.listen mainToolbar, dm.ui.Toolbar.EventType.SAVE_MODEL, (ev) ->
  name = actualModel.name.toLowerCase()
  model = JSON.stringify actualModel.toJSON()

  form = goog.dom.createDom(
    'form', {action: '/save', method: 'POST'}
    goog.dom.createDom 'input', {type: 'hidden', name: 'name', value: name }
    goog.dom.createDom 'input', {type: 'hidden', name: 'model', value: model }
  )

  form.submit()

goog.events.listen mainToolbar, dm.ui.Toolbar.EventType.LOAD_MODEL, (ev) ->
  loadModelDialog.show yes

###*
* @param {string} value
* @return {(boolean|number|string)}
###
columnCoercion = (value) ->
  if value is 'true' then true
  else if value is 'false' then false
  else if goog.string.isNumeric value then goog.string.toNumber value
  else value

goog.events.listen loadModelDialog, dm.dialogs.LoadModelDialog.EventType.CONFIRM, (ev) ->
  json = (`/** @type {Object} */`) ev.model

  actualModel = new dm.model.Model json.name

  for table in json.tables
    columns = (for column in table.model.columns 
      column[name] = columnCoercion(value) for name, value of column
      column
    )

    tableModel = new dm.model.Table table.model.name, columns
    
    for columnId, columnIndexes of table.model.indexes
      column = goog.string.toNumber(columnId)

      # foreign key indexes are created by relation
      for index in columnIndexes when index isnt dm.model.Table.index.FK
        tableModel.setIndex column, index 
      
    table = dm.addTable tableModel, table.pos.x, table.pos.y

  for relation in json.relations
    relationModel = new dm.model.Relation relation.type 
    dm.addRelation(
      relationModel
      actualModel.getTableIdByName relation.tables.parent
      actualModel.getTableIdByName relation.tables.child
    )

###*
* @param {dm.model.Table} model
* @param {number} x Horizontal coordinate of table position
* @param {string} y Vertical coordinate of table position
* @return {string} id of created table
###
dm.addTable = (model, x, y) ->
  tab = new dm.ui.Table model, x, y
  canvas.addTable tab
  actualModel.addTable tab
  tab.getId()

###*
* @param {dm.model.Relation} model
* @param {string} parentId Id of parent table
* @param {string} childId Id of child table
* @return {string} id of created relation
###
dm.addRelation = (model, parentId, childId) ->
  rel = new dm.ui.Relation model
  rel.setRelatedTables canvas.getChild(parentId), canvas.getChild(childId)
  canvas.addRelation rel
  actualModel.addRelation rel
  rel.getId()

#dm.getActualModel = ->
# actualModel
#goog.events.listen tableDialog, dm.dialogs.TableDialog.EventType.CONFIRM, (ev) ->
#   dm.actualModel.setTable ev.tableId, ev.tableName, ev.tableColumns

#goog.events.listen relationDialog, dm.dialogs.RelationDialog.EventType.CONFIRM, (ev) ->
#   dm.actualModel.setRelation ev.relationId, ev.identifying, ev.parentTable, ev.childTable

#goog.exportSymbol 'dm.init', dm.init
goog.provide 'dm'

goog.require 'dm.model.Table'
goog.require 'dm.model.Relation'
goog.require 'dm.ui.Table'
goog.require 'dm.ui.Relation'

goog.require 'dm.ui.SelectDbDialog'
goog.require 'dm.ui.TableDialog'
goog.require 'dm.ui.RelationDialog'
goog.require 'dm.ui.LoadModelDialog'
goog.require 'dm.model.Model'
goog.require 'dm.model.Table.index'
goog.require 'dm.ui.Canvas'
goog.require 'dm.ui.Toolbar'
goog.require 'dm.ui.Toolbar.EventType'
goog.require 'dm.sqlgen.Sql92'
goog.require 'goog.dom'
goog.require 'goog.events'

tableDialog = React.renderComponent(
  dm.ui.TableDialog(types: dmAssets.types)
  goog.dom.getElement 'tableDialog'
)

relationDialog = React.renderComponent(
  dm.ui.RelationDialog()
  goog.dom.getElement 'relationDialog' 
)

loadModelDialog = React.renderComponent(
  dm.ui.LoadModelDialog onModelLoad: (json) -> dm.createModelFromJSON(json)
  goog.dom.getElement 'loadModelDialog' 
)

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

goog.events.listen canvas, dm.ui.Table.EventType.MOVE, (e) ->
  relationsIds = actualModel.getRelationsByTable(e.target.getId())

  for relId in relationsIds
    relation = actualModel.getRelationUiById relId 
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
      parent: id: parent, name: actualModel.getTableById(parent).getName()
      child: id: child, name: actualModel.getTableById(child).getName()

    relationDialog.show model, tables
  else if object instanceof dm.ui.Table
    tableDialog.show model

goog.events.listen mainToolbar, dm.ui.Toolbar.EventType.CREATE, (ev) ->
  switch ev.objType
    when 'table'
      model = new dm.model.Table()
      dm.addTable model, ev.data.x, ev.data.y
      tableDialog.show model
    when 'relation'
      {parent, child, identifying} = ev.data
      #rel.setRelatedTables parent.getModel(), child.getModel() 

      model = new dm.model.Relation identifying, parent, child
      tables = 
        parent: id: parent, name: actualModel.getTableById(parent).getName()
        child: id: child, name: actualModel.getTableById(child).getName()

      dm.addRelation model
      relationDialog.show model, tables

goog.events.listen mainToolbar, dm.ui.Toolbar.EventType.GENERATE_SQL, (ev) ->
  generator = new dm.sqlgen.Sql92

  generator.generate(
    tables: actualModel.getTables()
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
  loadModelDialog.show()

###*
* @param {string} value
* @return {(boolean|number|string)}
###
dm.columnCoercion = (value) ->
  if value is 'true' then true
  else if value is 'false' then false
  else if goog.string.isNumeric value then goog.string.toNumber value
  else value

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
* @return {string} id of created relation
###
dm.addRelation = (model) ->
  rel = new dm.ui.Relation model
  parentTable = actualModel.getTableUiById model.tables.parent
  childTable = actualModel.getTableUiById model.tables.child

  goog.events.listen model, 'type-change', -> 
    rel.onTypeChange childTable.getModel()

  columnsListChangeEvents = ['column-add', 'column-change' ,'column-delete']
  
  goog.events.listen parentTable.getModel(), columnsListChangeEvents, ->
    rel.recountPosition parentTable.getElement(), childTable.getElement()

  goog.events.listen childTable.getModel(), columnsListChangeEvents, ->
    rel.recountPosition parentTable.getElement(), childTable.getElement()
  
  #rel.setRelatedTables canvas.getChild(parentId), canvas.getChild(childId)
  canvas.addRelation rel
  actualModel.addRelation rel
  rel.getId()

###*
* @param {Object} json JSON representation of model
###
dm.createModelFromJSON = (json) ->
  actualModel = new dm.model.Model json.name

  for table in json.tables
    columns = (for id, column of table.model.columns 
      column[colProp] = dm.columnCoercion(value) for colProp, value of column
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
    dm.addRelation(new dm.model.Relation(
        relation.type
        actualModel.getTableIdByName relation.tables.parent
        actualModel.getTableIdByName relation.tables.child
      )
    )

#dm.getActualModel = -> actualModel
#goog.exportSymbol 'dm.init', dm.init

###
tab0model = new dm.model.Table 'Person', [
  { name:'person_id', type:'smallint', isNotNull:false }
  { name:'name', type:'varchar', isNotNull:false }
]
tab0model.setIndex 0, dm.model.Table.index.PK
tab0 = dm.addTable tab0model, 100, 75

tab1model = new dm.model.Table 'Account', [
  { name:'account_id', type:'smallint', isNotNull:false }
  { name:'account_number', type:'numeric', isNotNull:false }
]
tab1model.setIndex 0, dm.model.Table.index.PK
tab1 = dm.addTable tab1model, 500, 280

tab2model = new dm.model.Table 'PersonAccount'
tab2 = dm.addTable tab2model, 100, 280

tab3model = new dm.model.Table 'AccountType', [
  { name:'acctype_id', type:'smallint', isNotNull:false }
  { name:'code', type:'numeric', isNotNull:false }
  { name:'name', type:'varchar', isNotNull:false }
  { name:'description', type:'varchar', isNotNull:false }
]
tab3model.setIndex 0, dm.model.Table.index.PK
tab3 = dm.addTable tab3model, 600, 50

rel1 = new dm.model.Relation true, tab0, tab2
dm.addRelation rel1

rel2 = new dm.model.Relation true, tab1, tab2
dm.addRelation rel2

rel3 = new dm.model.Relation false, tab1, tab3
dm.addRelation rel3
###
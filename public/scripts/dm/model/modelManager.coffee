goog.provide 'dm.model.ModelManager'

goog.require 'dm.model.Model'
goog.require 'dm.model.Table'
goog.require 'dm.model.Table.index'
goog.require 'dm.model.Relation'
goog.require 'dm.ui.Table'
goog.require 'dm.ui.Relation'

goog.require 'goog.events'
goog.require 'goog.string'
goog.require 'goog.events.EventTarget'

class dm.model.ModelManager extends goog.events.EventTarget
  @EventType:
    CHANGE: 'model-change'

  ###*
  * @constructor
  * @extends {goog.events.EventTarget}
  ###
  constructor: (canvas) ->
    super()

    @canvas = canvas

    ###*
    * @type {dm.model.Model}
    ###
    @actualModel = null

    ###*
    * @type {Object.<string, dm.model.Model>}
    ###
    @oldModels = {}

  ###*
  * Add table to actual model and create it at canvas
  *
  * @param {dm.model.Table} model
  * @param {number} x Horizontal coordinate of table position
  * @param {string} y Vertical coordinate of table position
  * @return {string} id of created table
  ###
  addTable: (model, x, y) ->
    tab = new dm.ui.Table model, x, y
    @canvas.addTable tab
    @actualModel.addTable tab

    tab.getId()

  ###*
  * Add relation to actual model and create it at canvas
  *
  * @param {dm.model.Relation} model
  * @return {string} id of created relation
  ###
  addRelation: (model) ->
    rel = new dm.ui.Relation model
    parentTable = @actualModel.getTableUiById model.tables.parent
    childTable = @actualModel.getTableUiById model.tables.child

    goog.events.listen model, 'type-change', -> 
      rel.onTypeChange childTable.getModel()

    columnsListChangeEvents = ['column-add', 'column-change' ,'column-delete']
    
    goog.events.listen parentTable.getModel(), columnsListChangeEvents, ->
      rel.recountPosition parentTable.getElement(), childTable.getElement()

    goog.events.listen childTable.getModel(), columnsListChangeEvents, ->
      rel.recountPosition parentTable.getElement(), childTable.getElement()
    
    @canvas.addRelation rel
    @actualModel.addRelation rel
    
    rel.getId()

  ###*
  * @param {string} name Model name
  * @param {Array.<Object>} tables List of tables at form at which they was saved
  *  at filesystem
  * @param {Array.<Object>} relations List of relations
  ###
  createActualFromLoaded: (name, tables, relations) ->
    @bakupOldCreateNewActual name

    for table in tables
      columns = (for id, column of table.model.columns 
        column[colProp] = @columnCoercion(value) for colProp, value of column
        column
      )

      tableModel = new dm.model.Table table.model.name, columns
      
      for columnId, columnIndexes of table.model.indexes
        column = goog.string.toNumber(columnId)

        # foreign key indexes are created by relation
        for index in columnIndexes when index isnt dm.model.Table.index.FK
          tableModel.setIndex column, index 
        
      @addTable tableModel, table.pos.x, table.pos.y

    for relation in relations
      @addRelation(
        new dm.model.Relation(
          relation.type
          @actualModel.getTableIdByName relation.tables.parent
          @actualModel.getTableIdByName relation.tables.child
        )
      )
   
  ###*
  * @param {string} name Name of new actual model
  * @param {Array.<Object>} columns List of columns got by reverse engeneering
  *  from database
  * @param {Array.<Object>} relations List of relations got by reverse 
  *  engeneering from database
  ###
  createActualFromCatalogData: (name, columns, relations) ->
    actualTableName = null
    canvasSize = @canvas.getSize()

    @bakupOldCreateNewActual name

    # first create tables
    for column, i in columns
      unless actualModel?
        actualTableName = column.table_name
        actualModel = new dm.model.Table actualTableName

      # dont create foreign key columns, they are created by relation
      unless column.isfk
        colId = actualModel.setColumn { 
          name: column.column_name
          type: column.data_type
          isNotNull: column.isnotnull 
        }

        actualModel.setIndex colId, dm.model.Table.index.PK if column.ispk
        actualModel.setIndex colId, dm.model.Table.index.UNIQUE if column.isunique
        actualModel.setIndex colId, dm.model.Table.index.FK if column.isfk

      # last column in list = next doesnt exists or next column from different 
      # table means that model is completed
      if not (columns[i + 1]?.table_name is actualTableName)
        @addTable(
          actualModel
          Math.round(Math.random() * canvasSize.width)
          Math.round(Math.random() * canvasSize.height)
        )
        actualModel = null  

    # then create relations
    for relation in relations
      @addRelation(new dm.model.Relation(
          relation.is_identifying
          @actualModel.getTableIdByName relation.parent_table
          @actualModel.getTableIdByName relation.child_table
        )
      )

  ###*
  * @param {string} name Name of new model
  ###
  bakupOldCreateNewActual: (name) =>
    if @actualModel? then @oldModels[@actualModel.name] = @actualModel
    
    @actualModel = new dm.model.Model name

    @dispatchEvent dm.model.ModelManager.EventType.CHANGE

  ###*
  * @param {string} value
  * @return {(boolean|number|string)}
  ###
  columnCoercion: (value) ->
    if value is 'true' then true
    else if value is 'false' then false
    else if goog.string.isNumeric value then goog.string.toNumber value
    else value
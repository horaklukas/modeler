goog.provide 'dm.model.ModelManager'

goog.require 'dm.model.Model'
goog.require 'dm.model.Table'
goog.require 'dm.model.Table.index'
goog.require 'dm.model.Relation'
goog.require 'dm.ui.Table'
goog.require 'dm.ui.Relation'

goog.require 'goog.events'
goog.require 'goog.object'
goog.require 'goog.string'
goog.require 'goog.events.EventTarget'

class dm.model.ModelManager extends goog.events.EventTarget
  @EventType:
    CHANGE: 'model-change'
    EDITED: 'model-edited'

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

    tableEvents = ['name-change','column-add','column-change','column-delete']
    
    goog.events.listen model, tableEvents, @onModelEdit
    goog.events.listen tab, dm.ui.Table.EventType.MOVED, @onModelEdit

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

    goog.events.listen model, 'type-change', => 
      rel.onTypeChange childTable.getModel()
      @onModelEdit()

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

    tableIdxsByName = {}

    for table, idx in tables
      columns = {}
      {indexes} = table.model

      goog.object.forEach table.model.columns, (column, id) => 
        if indexes?[id]? and dm.model.Table.index.FK in indexes[id]
          return 
        
        columns[id] = {}
        columns[id][prop] = @columnCoercion(value) for prop, value of column

      tableModel = new dm.model.Table table.model.name, columns
  
      # this is useful when creating relations
      tableIdxsByName[table.model.name] = idx 

      for columnId, columnIndexes of indexes
        # foreign key indexes are created by relation
        for index in columnIndexes when index isnt dm.model.Table.index.FK
          tableModel.setIndex columnId, index 
        
      @addTable tableModel, table.pos.x, table.pos.y

    for relation in relations
      {parent, child} = relation.tables
      parentId = @actualModel.getTableIdByName parent
      childId = @actualModel.getTableIdByName child

      @addRelation new dm.model.Relation(relation.type, parentId, childId)

      childTable = @actualModel.getTableById childId

      for mapping in relation.mapping
        # since column was created by relation, it hasnt id saved at json, but
        # has any newly created, so we must get it and the best solution is
        # by name, because name of column and corresponding parent table column
        # should equal
        columnId = childTable.getColumnIdByName(
          tables[tableIdxsByName[parent]].model.columns[mapping.parent].name
        )

        childTable.setColumn(
          tables[tableIdxsByName[child]].model.columns[mapping.child], columnId
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
      unless tableModel?
        actualTableName = column.table_name
        tableModel = new dm.model.Table actualTableName

      # dont create foreign key columns, they are created by relation
      unless column.isfk
        colId = tableModel.setColumn { 
          name: column.column_name
          type: column.data_type
          isNotNull: column.isnotnull 
        }

        tableModel.setIndex colId, dm.model.Table.index.PK if column.ispk
        tableModel.setIndex colId, dm.model.Table.index.UNIQUE if column.isunique
        tableModel.setIndex colId, dm.model.Table.index.FK if column.isfk

      # last column in list = next doesnt exists or next column from different 
      # table means that model is completed
      if not (columns[i + 1]?.table_name is actualTableName)
        @addTable(
          tableModel
          Math.round(Math.random() * canvasSize.width)
          Math.round(Math.random() * canvasSize.height)
        )
        tableModel = null  

    # then create relations
    for relation, i in relations
      childId = @actualModel.getTableIdByName relation.child_table

      if relations[i - 1]?.parent_table isnt relation.parent_table or
      relations[i - 1]?.child_table isnt relation.child_table
        parentId = @actualModel.getTableIdByName relation.parent_table

        @addRelation new dm.model.Relation(
          relation.is_identifying, parentId, childId
        )

      childTable = @actualModel.getTableById childId

      
      # since column was created by relation, it hasnt id saved at json, but
      # has any newly created, so we must get it and the best solution is
      # by name, because name of column and corresponding parent table column
      # should equal
      columnId = childTable.getColumnIdByName(relation.parent_column)
      childColumn = childTable.getColumnById columnId
      childColumn.name = relation.child_column

      childTable.setColumn childColumn, columnId
        
      ###
      @addRelation(new dm.model.Relation(
          relation.is_identifying
          @actualModel.getTableIdByName relation.parent_table
          @actualModel.getTableIdByName relation.child_table
        )
      )
      ###

  onModelEdit: =>
    @dispatchEvent dm.model.ModelManager.EventType.EDITED

  ###*
  * @param {string} name Name of new model
  ###
  bakupOldCreateNewActual: (name) =>
    if @actualModel? then @oldModels[@actualModel.name] = @actualModel
    
    @canvas.clear()
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
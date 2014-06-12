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

      relationModel = new dm.model.Relation(relation.type, parentId, childId)
      @addRelation relationModel

      childTable = @actualModel.getTableById childId

      for mapping in relation.mapping
        # since column was created by relation, it hasnt id saved at json, but
        # has any newly created, so we must get it and the best solution is
        # from relation mapping by parent column - we know its id (id from 
        # loaded model is used)
        columnId = relationModel.getOppositeMappingId mapping.parent

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

      # last column in list = next doesnt exists or next column from different 
      # table means that model is completed
      if not (columns[i + 1]?.table_name is actualTableName)
        @addTable(
          tableModel
          Math.round(Math.random() * canvasSize.width)
          Math.round(Math.random() * canvasSize.height)
        )
        tableModel = null  

    @spaceOutTablesByRelation relations

    # then create relations
    for relation, i in relations
      {parent_table, child_table} = relation

      if relations[i - 1]?.parent_table isnt parent_table or
      relations[i - 1]?.child_table isnt child_table
        childId = @actualModel.getTableIdByName child_table
        parentId = @actualModel.getTableIdByName parent_table
  
        childTable = @actualModel.getTableById childId
        parentTable = @actualModel.getTableById parentId

        relationModel = new dm.model.Relation(
          relation.is_identifying, parentId, childId
        )

        @addRelation relationModel
      
      # since column was created by relation, it hasnt id saved at json, but
      # has any newly created, so we must get it from relation mapping, because
      # we know name of parent column, its easy to find its id and the id of
      # opposite child column
      columnId = relationModel.getOppositeMappingId(
        parentTable.getColumnIdByName(relation.parent_column)
      )
      childColumn = childTable.getColumnById columnId
      childColumn.name = relation.child_column

      childTable.setColumn childColumn, columnId

  spaceOutTablesByRelation: (relations) ->
    tablesByName = @actualModel.getTablesUiByName()
    canvasSize = @canvas.getSize()
    relatedTables = []

    for relation in relations
      parent = relation.parent_table
      child = relation.child_table
      parentSize = tablesByName[parent].getSize()
      childSize = tablesByName[child].getSize()

      added = false
      for group, i in relatedTables
        if goog.array.contains(group.tables, child) or
        goog.array.contains(group.tables, parent)
          goog.array.insert relatedTables[i].tables, parent
          goog.array.insert relatedTables[i].tables, child

          relatedTables[i].max.w = Math.max parentSize.width, childSize.width
          relatedTables[i].max.h = Math.max parentSize.height, childSize.height

          added = true
          break 

      # neither one table belongs to any existing group of related table
      if added is false
        relatedTables.push {
          max: {
            w: Math.max(parentSize.width, childSize.width)
            h: Math.max parentSize.height, childSize.height
          }
          tables: [parent, child]
        }

    # divide groups into sectors, count viewport for each sector and place
    # groups's tables randomly somewhere there 
    groupsMatrixSize = Math.ceil Math.sqrt(relatedTables.length)
    canvasSectorWidth = canvasSize.width / groupsMatrixSize
    canvasSectorHeight = canvasSize.height / groupsMatrixSize

    for group, i in relatedTables
      row = Math.floor i / groupsMatrixSize 
      col = Math.floor i % groupsMatrixSize

      for tabname in group.tables
        # max position is sector right (bottom) edge minus max group's table
        # width (height)
        x = Math.min(
          Math.round((row + Math.random()) * canvasSectorWidth)
          ((row + 1) * canvasSectorWidth - group.max.w)
        )
        y = Math.min(
          Math.round((col + Math.random()) * canvasSectorHeight)
          ((col + 1) * canvasSectorHeight - group.max.h)
        )

        tablesByName[tabname].setPosition x, y

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
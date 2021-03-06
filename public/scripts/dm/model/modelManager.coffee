goog.provide 'dm.model.ModelManager'

goog.require 'dm.model.Model'
goog.require 'dm.model.Table'
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
  * @param {string=} id Id of table component
  * @return {string} id of created table
  ###
  addTable: (model, x, y, id) ->
    tab = new dm.ui.Table model, x, y, id
    @canvas.addTable tab
    @actualModel.addTable tab

    tableEvents = ['name-change','column-add','column-change','column-delete']
    
    goog.events.listen model, tableEvents, @onModelEdit
    goog.events.listen tab, dm.ui.Table.EventType.MOVED, @onModelEdit

    # enable bubbling and catching object events on modelManager
    model.setParentEventTarget this

    tab.getId()

  ###*
  * Add relation to actual model and create it at canvas
  *
  * @param {dm.model.Relation} model
  * @param {string=} id Id of relation component
  * @return {string} id of created relation
  ###
  addRelation: (model, id) ->
    rel = new dm.ui.Relation model, id
    parentTable = @actualModel.getTableUiById model.tables.parent
    childTable = @actualModel.getTableUiById model.tables.child

    goog.events.listen model, 'type-change', => 
      rel.onTypeChange childTable.getModel()
      @onModelEdit()

    goog.events.listen model, 'cardinality-change', =>
      rel.setCardinalityMarkers model.getCardinalityParciality()
      @onModelEdit()

    columnsListChangeEvents = ['column-add', 'column-change' ,'column-delete']

    # this events need not to dispatch "model edited" event because its 
    # already done by table move (which bubble to recount rel position)    
    goog.events.listen(
      parentTable.getModel()
      columnsListChangeEvents
      goog.partial(@onParentColumnChange, rel, parentTable, childTable)
    )

    goog.events.listen childTable.getModel(), columnsListChangeEvents, ->
      rel.recountPosition parentTable.getElement(), childTable.getElement()
    
    @canvas.addRelation rel
    @actualModel.addRelation rel
    
    rel.getId()

  ###*
  * Called when any column of relation's parent table is changed
  *
  * @param {dm.ui.Relation} rel
  * @param {dm.ui.Table} parentTable
  * @param {dm.ui.Table} childTable
  * @param {dm.model.Table.ColumnsChange} ev
  ###
  onParentColumnChange: (rel, parentTable, childTable, {type, column}) =>
    model = rel.getModel()
    relMappings = model.getColumnsMapping()
    identifying = model.isIdentifying()

    childModel = childTable.getModel()

    rel.recountPosition parentTable.getElement(), childTable.getElement()

    switch type
      when 'column-delete' 
        if relMappings.length is 1 and relMappings[0]['parent'] is column.id
          @deleteRelation rel
        else if relMappings.length > 1
          # primary key at parent table has more columns so relation not need
          # to be deleted when one of them is deleted
          for mapping, idx in relMappings when mapping['parent'] is column.id 
            childTable.removeColumn mapping['child'] 
            model.removeMapping idx

      when 'column-add'
        # add only parent table pkeys that wasnt created by other relation
        if not column.data.indexes? or
        not goog.array.contains(column.data.indexes, dm.model.Table.index.PK) or goog.array.contains column.data.indexes, dm.model.Table.index.FK
          break

        id = rel.addForeignKeyColumn column.data, childModel, identifying

        goog.array.insert relMappings, { 'parent': column.id, 'child': id }  
        model.setColumnsMapping relMappings

      when 'column-change'
        childId = model.getOppositeMappingId column.id

        break unless childId?

        # if parent column changed to not be primary key
        #unless goog.array.contains column.data.indexes, dm.model.Table.index.PK

        childColumn = childModel.getColumnById childId 
        childColumn.type = column.data.type
        childColumn.length = column.data.length
        #childModel.setColumn childColumn, childId

  ###*
  * @param {dm.ui.Table} table
  ###
  deleteTable: (table) ->
    model = table.getModel()

    goog.events.removeAll table
    goog.events.removeAll model

    @actualModel.removeTable table.getId() 
    @canvas.removeTable table

  ###*
  * @param {dm.ui.Relation} relation
  ###
  deleteRelation: (relation) ->
    model = relation.getModel()
    childTable = @actualModel.getTableById model.tables.child

    relation.removeRelatedTablesKeys childTable

    goog.events.removeAll relation
    goog.events.removeAll model

    @actualModel.removeRelation relation.getId() 
    @canvas.removeRelation relation


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
      indexes = table['model']['indexes']
      tabName = table['model']['name']

      goog.object.forEach table['model']['columns'], (column, id) => 
        if indexes?[id]? and dm.model.Table.index.FK in indexes[id]
          return 
        
        columns[id] = {}
        columns[id][prop] = @columnCoercion(value) for prop, value of column

      tableModel = new dm.model.Table tabName, columns
  
      # this is useful when creating relations
      tableIdxsByName[tabName] = idx 

        # foreign key column's indexes are created by relation
      for columnId, columnIndexes of indexes when not goog.array.contains columnIndexes, dm.model.Table.index.FK
        for index in columnIndexes when index isnt dm.model.Table.index.FK
          tableModel.setIndex columnId, index 
        
      @addTable tableModel, table['pos']['x'], table['pos']['y'], table['__id__']

    for relation in relations
      model = relation['model']
      parent = model['tables']['parent']
      child = model['tables']['child']

      parentId = @actualModel.getTableIdByName parent 
      childId = @actualModel.getTableIdByName child

      relationModel = new dm.model.Relation(
        model['type'], parentId, childId, model['name']
      )
      relationModel.setCardinalityParciality(
        model['cardinality'], model['parciality']
      )

      @addRelation relationModel, relation['__id__']

      childTable = @actualModel.getTableById childId

      for mapping in model['mapping']
        # since column was created by relation, it hasnt id saved at json, but
        # has any newly created, so we must get it and the best solution is
        # from relation mapping by parent column - we know its id (id from 
        # loaded model is used)
        columnId = relationModel.getOppositeMappingId mapping['parent']

        childTable.setColumn(
          tables[tableIdxsByName[child]]['model']['columns'][mapping['child']]
          columnId
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
        actualTableName = column['table_name']
        tableModel = new dm.model.Table actualTableName

      # dont create foreign key columns, they are created by relation
      unless column['isfk']
        colId = tableModel.setColumn { 
          name: column['column_name']
          type: column['data_type']
          isNotNull: column['isnotnull'] 
          length: if column['length'] then column['length'] else null
        }

        tableModel.setIndex colId, dm.model.Table.index.PK if column['ispk']
        tableModel.setIndex colId, dm.model.Table.index.UNIQUE if column['isunique']

      # last column in list = next doesnt exists or next column from different 
      # table means that model is completed
      if not (columns[i + 1]?['table_name'] is actualTableName)
        @addTable(
          tableModel
          Math.round(Math.random() * canvasSize.width)
          Math.round(Math.random() * canvasSize.height)
        )
        tableModel = null  

    @spaceOutTablesByRelation relations

    # then create relations
    for relation, i in relations
      relParentId = relation['parent_table']
      relChildId = relation['child_table']

      if relations[i - 1]?['parent_table'] isnt relParentId or
      relations[i - 1]?['child_table'] isnt relChildId
        childId = @actualModel.getTableIdByName relChildId
        parentId = @actualModel.getTableIdByName relParentId
  
        childTable = @actualModel.getTableById childId
        parentTable = @actualModel.getTableById parentId

        relationModel = new dm.model.Relation(
          relation['is_identifying'], parentId, childId, relation['name']
        )

        @addRelation relationModel
      
      # since column was created by relation, it hasnt id saved at json, but
      # has any newly created, so we must get it from relation mapping, because
      # we know name of parent column, its easy to find its id and the id of
      # opposite child column
      columnId = relationModel.getOppositeMappingId(
        parentTable.getColumnIdByName(relation['parent_column'])
      )
      childColumn = childTable.getColumnById columnId
      childColumn.name = relation['child_column']

      childTable.setColumn childColumn, columnId

  spaceOutTablesByRelation: (relations) ->
    tablesByName = @actualModel.getTablesUiByName()
    # tables without any relation - start with full list of tables and for each
    # relation remove its parent and child table from list
    aloneTables = goog.object.getKeys tablesByName
    canvasSize = @canvas.getSize()
    relatedTables = []

    for relation in relations
      parent = relation['parent_table']
      child = relation['child_table']
      parentSize = tablesByName[parent].getSize()
      childSize = tablesByName[child].getSize()

      goog.array.remove aloneTables, parent
      goog.array.remove aloneTables, child

      added = false
      for group, i in relatedTables
        if goog.array.contains(group.tables, child) or
        goog.array.contains(group.tables, parent)
          goog.array.insert relatedTables[i].tables, parent
          goog.array.insert relatedTables[i].tables, child

          relatedTables[i].max.w = Math.max(
            relatedTables[i].max.w, parentSize.width, childSize.width
          )
          relatedTables[i].max.h = Math.max(
            relatedTables[i].max.h, parentSize.height, childSize.height
          )

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

    # there are tables without relation
    if aloneTables
      groupAlones = tables: aloneTables, max: {w: 0, h: 0}

      for aloneTab in aloneTables
        aloneSize = tablesByName[aloneTab].getSize()
        groupAlones.max =
          w: Math.max(aloneSize.width, groupAlones.max.w)
          h: Math.max(aloneSize.height, groupAlones.max.h)

      relatedTables.push groupAlones

    # divide groups into sectors, count viewport for each sector and place
    # groups's tables randomly somewhere there 
    groupsMatrixSize = Math.ceil Math.sqrt(relatedTables.length)
    canvasSectorWidth = canvasSize.width / groupsMatrixSize
    canvasSectorHeight = canvasSize.height / groupsMatrixSize

    for group, i in relatedTables
      row = Math.floor i / groupsMatrixSize 
      col = Math.floor i % groupsMatrixSize
      sector =
        min: 
          x: col * canvasSectorWidth
          y: row * canvasSectorHeight
        max:
          x: (col + 1) * canvasSectorWidth
          y: (row + 1) * canvasSectorHeight

      for tabname in group.tables
        # max x position is sector right edge minus max group's table width
        x = Math.min(
          sector.min.x + Math.round(Math.random() * canvasSectorWidth)
          sector.max.x - group.max.w
        )
        # max y position is sector bottom edge minus max group's table height
        y = Math.min(
          sector.min.y + Math.round(Math.random() * canvasSectorHeight)
          sector.max.y - group.max.h
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
  * @param {string} name
  ###
  changeActualModelName: (name) =>
    @actualModel.name = name
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
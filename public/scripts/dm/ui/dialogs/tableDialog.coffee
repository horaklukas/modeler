`/** @jsx React.DOM */`

goog.provide 'dm.ui.TableDialog'

goog.require 'goog.array'
goog.require 'goog.object'
goog.require 'goog.dom.classes'

###
goog.require 'goog.ui.Dialog'
goog.require 'goog.ui.Dialog.ButtonSet'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.soy'
goog.require 'goog.events'
goog.require 'goog.string'
goog.require 'dm.model.Table'
###

goog.require 'dm.ui.Dialog'

{Dialog} = dm.ui

dm.ui.TableDialog = React.createClass
  _originalModel: null
  removed: null
  changed: null

  show: (model) ->
    @_originalModel = model

    @removed = []
    @changed = []

    columns = []
    uniqs = model.getColumnsIdsByIndex dm.model.Table.index.UNIQUE
    pks = model.getColumnsIdsByIndex dm.model.Table.index.PK
    fks = model.getColumnsIdsByIndex dm.model.Table.index.FK

    columns = (for id, col of model.getColumns()
      id: id
      name: col.name
      type: col.type
      isNotNull: col.isNotNull ? false
      isUnique: uniqs? and id in uniqs
      isPk: pks? and id in pks
      isFk: fks? and id in fks
    )

    @setState 
      visible: true    
      name: model.getName()
      columns: columns

    # one more empty row for adding
    @addColumn()

  hide: ->
    @setState visible: false

  onConfirm: ->
    tableName = @refs.tableName.getDOMNode().value
    
    if tableName is ''
      @setState errorState: 'Table name have to be filled'
      return false

    @_originalModel.setName @state.name
    @_originalModel.removeColumn id for id in @removed

    for col in @state.columns
      {id} = col
      
      # new or updated columns
      model = name: col.name, type: col.type, isNotNull: !!col.isNotNull

      # new column has not id and column name is filled
      isNewColumn = not id? and col.name
      isChangedColumn = id in @changed

      unless isNewColumn or isChangedColumn then continue
      
      id = @_originalModel.setColumn model, id

      # index can be deleted (third param) only when column is changing, not
      # for new columns
      if isChangedColumn or isNewColumn and col.isUnique is true
        @_originalModel.setIndex(
          id, dm.model.Table.index.UNIQUE,
          isChangedColumn and not col.isUnique
        )
      
      if isChangedColumn or isNewColumn and col.isPk is true
        @_originalModel.setIndex(
          id, dm.model.Table.index.PK
          isChangedColumn and not col.isPk
        )

    @hide()
    #@_originalModel = null

  nameChange: (e) ->
    @setState name: e.target.value

  addColumn: ->
    for name, group of @props.types
      defaultType = group[0]
      break # we need only first type at first group

    columns = @state.columns
    columns.push {name: null, type: defaultType, isNotNull: null}
    
    @setState columns: columns

  ###*
  * Add column id to the list of those that should be removed
  * @param {string} index Index of column that should be removed at columns 
  * list 
  ###
  removeColumn: (index) ->
    {columns} = @state
    column = columns[index]
    
    if column.id then @removed.push column.id

    goog.array.removeAt columns, index
    @setState columns: columns

  changeColumn: (index, name, value) ->
    {columns} = @state
    column = columns[index]

    # set new value of changed column property
    column[name] = value
    columns[index] = column

    if column.id then @changed.push column.id

    @setState columns: columns

  getDefaultProps: ->
    types: {}
    
  getInitialState: ->
    name: null # table name
    columns: [] # table columns
    visible: false
    errorState: ''

  render: ->
    title = "Table \"#{@state.name or 'unnamed'}\""
    show = @state.visible

    `(
    <Dialog title={title} onConfirm={this.onConfirm} onCancel={this.hide} visible={show}>
      <div className="row">
        <span><label>Table name</label></span>
        <span>
          <input ref="tableName" value={this.state.name} 
            onChange={this.nameChange} />
        </span>
      </div>

      <strong>Table columns</strong>
      <ColumnsList columns={this.state.columns} types={this.props.types} 
        onColumnRemove={this.removeColumn}
        onColumnChange={this.changeColumn} />

      <button onClick={this.addColumn}>Add new column</button><br />
      <strong>* <small>foreign key columns can change only name</small></strong>

      <div className="info error">{this.state.errorState}</div>
    </Dialog>
    )`

ColumnsList = React.createClass
  createColumn: (col, index) ->
    `( <Column key={index} types={this.props.types} data={col}
          onRemove={this.props.onColumnRemove} 
          onChange={this.props.onColumnChange} /> )`

  render: ->
    titles = ['Name', 'Type', 'PK', 'Not NULL', 'Unique', '']
    head = goog.array.map titles, (title) ->
      `(<span>{title}</span>)`

    columns = goog.array.map @props.columns, @createColumn, this

    # last row is empty   
    `(
    <div>
      <div className="row head">{head}</div>
      {columns}
    </div>
    )`

Column = React.createClass
  handleRemove: ->
    @props.onRemove @props.key

  handleChange: (e) ->
    field = e.target

    classes = goog.dom.classes.get field
    #value = if type is 'checkbox' then field.checked else field.checked
    value = if field.type is 'checkbox' then field.checked else field.value

    @props.onChange @props.key, classes.join(''), value 

  render: ->
    {name, type, isPk, isFk, isUnique, isNotNull} = @props.data

    typesList = `(<TypesList types={this.props.types} disabled={isFk}
      selected={type} onTypeChange={this.handleChange} />)`

    `(
    <div className="row tableColumn" >
      <span>
        <strong>{isFk == true ? '*' : '  ' }</strong>
        <input type="text" className="name" value={name ? name : ''} 
          onChange={this.handleChange} />
      </span>
      <span>{typesList}</span>
      <span>
        <input type="checkbox" className="isPk" checked={isPk ? true : false} 
          disabled={isFk} onChange={this.handleChange} />
      </span>
      <span>
        <input type="checkbox" className="isNotNull" disabled={isFk ? true : false} checked={isNotNull} onChange={this.handleChange} />
      </span>
      <span>
        <input type="checkbox" className="isUnique" checked={isUnique ? true : false}
          disabled={isFk} onChange={this.handleChange} />
      </span>
      <span>
        <button className="delete" disabled={isFk ? true : false} onClick={this.handleRemove}>Del</button>
      </span>
    </div>
    )`

TypesList = React.createClass
  createType: (type, idx) ->
    key = "#{type}-#{idx}"

    `( <option key={key} value={type}>{type}</option> )`

  createGroup: (groupName, groupTypes) ->
    groupTypes = goog.array.map groupTypes, @createType

    `( <optgroup label={groupName}>{groupTypes}</optgroup> )`

  getDefaultProps: ->
    disabled: false, selected: null

  render: ->
    list = (@createGroup group, types for group, types of @props.types )
    {disabled, selected} = @props
    selected ?= null

    `( <select className="type" disabled={disabled} value={selected} 
        onChange={this.props.onTypeChange}>{list}</select> )`
`/*
goog.provide 'dm.dialogs.TableDialogBAKUP'


class dm.dialogs.TableDialogBAKUP extends goog.ui.Dialog
  @EventType =
    CONFIRM: goog.events.getUniqueId 'dialog-confirmed'

  constructor: (@types) ->
    super() #'createTable', types

    @setContent tmpls.dialogs.createTable.dialog {types: @types}
    @setButtonSet goog.ui.Dialog.ButtonSet.createOkCancel()
    @setDraggable false

    # force render dialog, so all control widgets exists since now
    content = @getContentElement()
    
    addBtn = goog.dom.getElementsByTagNameAndClass('button', 'add', content)[0]
    @nameField = goog.dom.getElement 'table_name'
    @colslist = goog.dom.getElement 'columns_list'

    @columns_ = removed: null, added: null, updated: null, count: 0

    # events 1) add new column 2) delete existing column 3) dialog ok or cancel
    goog.events.listen addBtn, goog.events.EventType.CLICK, @addColumn

    goog.events.listen @colslist, goog.events.EventType.CLICK, (e) =>
      if goog.dom.classes.has e.target, 'delete' then @removeColumn e.target  

    goog.events.listen @, goog.ui.Dialog.EventType.SELECT, @onSelect
    goog.events.listen @nameField, goog.events.EventType.KEYUP, @onNameChange

  ###* @override ###
  #enterDocument: ->
  # super()

  ###*
  * Show the dialog window
  * @param {boolean} show 
  * @param {dm.ui.Table=} table
  ###
  show: (show, table) ->
    if table?
      @table_ = table
      model = table.getModel()
      columnsCount = model.getColumns().length

      @columns_ = 
        # prepared empty row is counted as the first added
        removed: [], updated: [], added: [columnsCount], count: columnsCount

      @setValues model
      @setTitle "Table \"#{model.getName() or 'unnamed'}\""

      # @TODO change of inputs of rows added from model
      rows = goog.dom.getChildren @colslist
      
      # if table isnt empty (has only head and new column row) each row except
      # first (head row) and last (empty row) is row that is from original 
      # model, so its change is update
      if rows.length > 2
        for i in [1..rows.length - 2]
          row = rows[i]
          goog.events.listen row, goog.events.EventType.CHANGE, (e) =>
            columnRow = goog.dom.getAncestorByClass e.target, 'row'
            index = goog.string.toNumber columnRow.getAttribute 'name'

            # dont add column that already exists there 
            unless index in @columns_.updated then @columns_.updated.push index
      
      # disable OK button if table name not set (probably new table) 
      @onNameChange()
    
    @setVisible show

  ###*
  * @param {number} index Column index
  * @return {dm.model.TableColumn} model of columns with passed index
  ###
  getColumnData: (index) ->
    column = goog.dom.query "*[name='#{index}']", @colslist
      
    # that should never throw
    if column.length is 0 then throw new Error 'Column not exist!'

    # query returns node list, column element have to be selected
    [column] = column

    model:
      name: goog.dom.getElementByClass('name', column).value.replace ' ', '_'
      type: goog.dom.getElementByClass('type', column).value
      isNotNull:goog.dom.getElementByClass('notnull', column).checked
    isPk: goog.dom.getElementByClass('primary', column).checked
    isUnique:goog.dom.getElementByClass('unique', column).checked

  onNameChange: =>
    @getButtonSet().setButtonEnabled 'ok', @getName() isnt ''

  ###*
  * Return table name, filled in dialog
  * @return {string} Table name
  ###
  getName: ->
    @nameField.value

  ###*
  * Set table values (name and columns) to dialog, used when editing table
  *
  * @param {dm.model.Table=} model
  ###
  setValues: (model) ->
    name = model.getName() ? ''
    cols = model.getColumns() ? []
    uniqs = model.getColumnsIdsByIndex dm.model.Table.index.UNIQUE
    pks = model.getColumnsIdsByIndex dm.model.Table.index.PK
    fks = model.getColumnsIdsByIndex dm.model.Table.index.FK

    goog.dom.setProperties @nameField, 'value': name

    for col, id in cols
      if id in uniqs then cols[id].isUnique = true 
      if id in pks then cols[id].isPk = true
      if id in fks then cols[id].isFk = true

    @colslist.innerHTML = tmpls.dialogs.createTable.columnsList {
      types: @types, columns: cols 
    }

  ###*
  * Add new empty column row to the end of dialog
  *
  * @param {dm.model.TableColumn} column
  ###
  addColumn: =>
    opts = types: @types
    
    @columns_.count++
    opts.id = @columns_.count

    goog.dom.appendChild @colslist, goog.soy.renderAsElement(
      tmpls.dialogs.createTable.tableColumn, opts
    )

    @columns_.added.push @columns_.count

  ###*
  * @param {Element} deleteBtn Button element that invoked action
  ###
  removeColumn: (deleteBtn) =>
    columnRow = goog.dom.getAncestorByClass deleteBtn, 'row'
    index = goog.string.toNumber columnRow.getAttribute 'name'

    # if removing column isnt in model yet only remove column id from ids
    # prepared to add
    if index in @columns_.added then goog.array.remove @columns_.added, index
    else @columns_.removed.push index

    goog.dom.removeNode columnRow

  ###*
  * @param {goog.events.Event} e
  ###
  onSelect: (e) =>
    if e.key isnt 'ok' then return true

    model = @table_.getModel()

    model.setName @getName()

    # update earlie created columns and its indexes
    for id in @columns_.updated
      colData = @getColumnData(id)
      model.setColumn colData.model, id
      model.setIndex id, dm.model.Table.index.UNIQUE, not colData.isUnique
      model.setIndex id, dm.model.Table.index.PK, not colData.isPk
    
    # removed deleted columns
    model.removeColumn id for id in @columns_.removed
    
    # add columns (and its indexes) that have filled name
    for id in @columns_.added
      colData = @getColumnData(id) 
      
      if not colData.model.name? or colData.model.name is '' then continue
        
      colId = model.setColumn colData.model
      
      if colData.isUnique then model.setIndex colId, dm.model.Table.index.UNIQUE
      if colData.isPk then model.setIndex colId, dm.model.Table.index.PK


    #@table_.setModel model
    #confirmEvent =  new dm.dialogs.TableDialog.Confirm(@, @relatedTable, tabName, columns)

    #@dispatchEvent confirmEvent

#goog.addSingletonGetter dm.dialogs.TableDialog

###
class dm.dialogs.TableDialog.Confirm extends goog.events.Event
  constructor: (dialog, id, name, columns) ->
    super dm.dialogs.TableDialog.EventType.CONFIRM, dialog
###
###*
* @type {string}
###
#@tableId = id

###*
* @type {string}
###
#@tableName = name

###*
* @type {Array.<Object>}
###
#@tableColumns = columns
*/`
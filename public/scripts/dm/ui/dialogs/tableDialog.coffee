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
      length: col.length
      isNotNull: col.isNotNull ? false
      isUnique: uniqs? and id in uniqs
      isPk: pks? and id in pks
      isFk: fks? and id in fks
    )
    
    # one more empty row for adding
    columns.push @getEmptyColumnModel()

    @replaceState 
      visible: true    
      name: model.getName()
      columns: columns

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
      model.length = if col.length then goog.string.toNumber(col.length) else null

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
    columns = @state.columns
    columns.push @getEmptyColumnModel() 
    
    @setState columns: columns

  getEmptyColumnModel: ->
    for name, group of @props.types
      defaultType = group[0]
      break # we need only first type at first group

    name: null, type: defaultType, length: '', isNotNull: null

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
    {Dialog} = dm.ui
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
    titles = ['Name', 'Type', 'Length','PK', 'Not NULL', 'Unique', '']
    head = goog.array.map titles, (title) ->
      `(<span key={title.toLowerCase()}>{title}</span>)`

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

  checkLengthIsNumber: (ev) ->
    unless /[0-9]/.test String.fromCharCode(ev.charCode)
      ev.preventDefault() ; console.log('isnt num')

  handleChange: (e) ->
    field = e.target

    classes = goog.dom.classes.get field
    #value = if type is 'checkbox' then field.checked else field.checked
    value = if field.type is 'checkbox' then field.checked else field.value

    @props.onChange @props.key, classes.join(''), value 

  render: ->
    {name, type, length, isPk, isFk, isUnique, isNotNull} = @props.data

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
        <input type="text" className="length" value={length ? length : ''}
          size="5" disabled={isFk} onKeyPress={this.checkLengthIsNumber} 
          onChange={this.handleChange} />
      </span>
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

    `( <optgroup label={groupName} key={groupName}>{groupTypes}</optgroup> )`

  getDefaultProps: ->
    disabled: false, selected: null

  render: ->
    list = (@createGroup group, types for group, types of @props.types )
    {disabled, selected} = @props
    selected ?= null

    `( <select className="type" disabled={disabled} value={selected} 
        onChange={this.props.onTypeChange}>{list}</select> )`
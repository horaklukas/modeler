`/** @jsx React.DOM */`

goog.provide 'dm.dialogs.TableDialog'

goog.require 'goog.array'
goog.require 'goog.object'

goog.require 'goog.ui.Dialog'
goog.require 'goog.ui.Dialog.ButtonSet'
goog.require 'tmpls.dialogs.createTable'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.dom.query'
goog.require 'goog.soy'
goog.require 'goog.events'
goog.require 'goog.string'
goog.require 'dm.model.Table'

dm.dialogs.TableDialog = React.createClass
  addColumn: ->
    model = @state.table
    model.columns.push {}
    
    @setState table model

  getDefaultProps: ->
    types: {}
    
  getInitialState: ->
    table: name: null, columns: []
    displayed: false

  render: ->
    title = "Table \"#{@state.table.name or 'unnamed'}\""
    styles = 
      left: 153
      top: 60
      display: if @state.displayed then 'block' else 'none'

    `(
    <div className="modal-dialog dialog" style={styles}>
      <div className="title">{title}</div>
      <div className="content">
        <div className="row">
          <span><label>Table name</label></span>
          <span><input ref="name" defaultValue={this.state.table.name}/></span>
        </div>

        <strong>Table columns</strong>
        <ColumnsList columns={this.state.table.columns} types={this.props.types} />
        <button onClick={this.addColumn}>Add new column</button><br />
        <strong>* <small>foreign key columns can change only name</small></strong>
      </div>
      <div className="buttons">
        <button type="button">Ok</button>
        <button type="button">Cancel</button>
      </div>
    </div>
    )`

ColumnsList = React.createClass
  render: ->
    titles = ['Name', 'Type', 'PK', 'Not NULL', 'Unique', '']
    head = goog.array.map titles, (title) ->
      `(<span>{title}</span>)`

    columns = goog.array.map @props.columns, (col, index) ->
      `(
      <Column id={index} name={col.name} types={this.props.types}
        type={col.type} isPk={col.isPk} isFk={col.isFk} 
        isNotNull={col.isNotNull} isUnique={col.isUnique} />
      )`

    # last row is empty   
    `(
    <div>
      <div className="row head">{head}</div>
      {columns}

      <Column types={this.props.types} />
    </div>
    )`
Column = React.createClass
  render: ->
    typesList = `(<TypesList types={this.props.types} 
      disabled={!!this.props.isFk} selected={this.props.type} />)`

    `(
    <div className="row" name={this.props.id ? this.props.id : null} >
      <span>
        <strong>{this.props.isFk == true ? '*' : '  ' }</strong>
        <input type="text" className="name" value={name ? name : null} />
      </span>
      <span>{typesList}</span>
      <span>
        <input type="checkbox" className="primary" checked={this.props.isPk} 
          disabled={this.props.isFk} />
      </span>
      <span>
        <input type="checkbox" className="notnull" checked={this.props.isNotNull} disabled={this.props.isFk} />
      </span>
      <span>
        <input type="checkbox" className="unique" checked={this.props.isUnique}
          disabled={this.props.isFk} />
      </span>
      <span>
        <button className="delete" disabled={this.props.ifFk} >Del</button>
      </span>
    </div>
    )`

TypesList = React.createClass
  getDefaultProps: ->
    disabled: false, selected: null

  render: ->
    list = (for group, types of @props.types
      typesElements = goog.array.map types, ((type, idx) ->
        `(
        <option value={type}>
          {type}
        </option>
        )`
        ).bind this

      `(
      <optgroup label={group}>
        {typesElements}
      </optgroup>
      )`
    )

    `(
    <select disabled={this.props.disabled} value={this.props.selected}>
      {list}
    </select>
    )`

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
        # prepared empty row is counted as the first `added`
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
  * Add new empty `column` row to the end of dialog
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
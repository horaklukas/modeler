`/** @jsx React.DOM */`

goog.provide 'dm.ui.SelectDbDialog'

goog.require 'dm.ui.Dialog'
goog.require 'goog.net.XhrIo'
goog.require 'goog.events'
goog.require 'goog.object'
goog.require 'goog.array'

dm.ui.SelectDbDialog = React.createClass
  show: (cb) ->
    for id, db of @props.dbs
      name = db.name
      dbId = id
      break

    if cb? then @setProps onSelect: cb
    @setState {visible: true, dbName: name, dbId: dbId}

  handleDbSelect: ->
    @props.onSelect? @state.dbId
    @setState visible: false

  getInitialState: ->
    visible: false
    info: text: '', err: false
    dbName: null, dbId: null

  handleSelectName: ({target}) ->
    @setState dbName: target.value

  handleSelectVersion: ({target}) ->
    @setState dbId: target.value

  render: ->
    {Dialog} = dm.ui
    title = 'Select database to work with'
    buttonSetType = Dialog.buttonSet.SELECT
    dbsList = []

    infoClass = 'state' + (if @state.info.err then ' error' else '')
    
    dbNames = []
    versions = []

    goog.object.forEach @props.dbs, (db, id) =>
      goog.array.insert dbNames, db.name
      
      if db.name is @state.dbName
        goog.array.insert(
          versions, `( <option key={id} value={id}>{db.version}</option> )`
        )

    dbsList = goog.array.map dbNames, (name) =>
      selected = name is @state.dbName
      `( <option key={name} value={name} selected={selected}>{name}</option> )`


    `(
    <Dialog title={title} buttons={buttonSetType} visible={this.state.visible}
      onConfirm={this.handleDbSelect}
     >
      <strong>List of databases</strong>

      <div className={infoClass}>{this.state.info.text}</div>

      <select onChange={this.handleSelectName}>{dbsList}</select>
      <select onChange={this.handleSelectVersion}>{versions}</select>
    </Dialog>
    )`
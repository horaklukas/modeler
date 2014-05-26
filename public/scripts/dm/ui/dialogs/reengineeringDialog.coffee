`/** @jsx React.DOM */`

goog.provide 'dm.ui.ReEngineeringDialog'

goog.require 'dm.ui.Dialog'
#goog.require 'goog.array'
goog.require 'goog.object'

{Dialog} = dm.ui

dm.ui.ReEngineeringDialog = React.createClass
  show: ->
    @setState visible: true

  hide: ->
    @setState visible: false

  handleDbConnection: ->
    type = @refs.dbtype.getDOMNode().value
    pass = @refs.pass.getDOMNode().value
    port = @refs.port.getDOMNode().value
    connectOptions =
      host: @refs.host.getDOMNode().value
      db: @refs.db.getDOMNode().value
      user: @refs.user.getDOMNode().value
      pass: if pass is '' then null else pass
      port: if port is '' then null else port

    @props.connection.emit 'connect-db', type, connectOptions, (err, data) =>
      if err then @setState info: {text: err, err: true}
      else @setState data: data

    # dont hide dialog until process is complete
    return false

  handleSchemaSelect: ->


  handleTablesSelected: ->
    selectedTables = []

    goog.object.forEach @refs, ((ref, name) ->
      if ref.getDOMNode().checked
        selectedTables.push @state.data.tables[name.substr(5)]
    ), this

    @props.connection.emit 'get-reeng-data', selectedTables, (err, data) =>
      if err then return @setState info: {text: err, err: true}

      @props.onDataReceive data.tables, data.relations
      @hide()

  createContent: (type) ->
    switch type
      when 'dbconnect'
        dbTypes = []
        addedTypes = []

        goog.object.forEach @props.dbs, (db, id) ->
          # id of db has format dbtype-dbversion so first part is only what we
          # need
          dbId = id.split('-')[0]

          # db type already in list
          return if goog.array.contains addedTypes, dbId

          addedTypes.push dbId
          dbTypes.push `(<option key={dbId} value={dbId}>{db.name}</option>)`

        `(
          <form>
            <p><select ref="dbtype">{dbTypes}</select></p>
            <p>Hostname <input type="text" ref="host" /></p>
            <p>Database<input type="text" ref="db" /></p>
            <p>Username<input type="text" ref="user" /></p>
            <p>Password<input type="text" ref="pass" /></p>
            <p>Port<input type="text" ref="port" /></p>
          </form>
        )`
      when 'selectschema'
        `(
          <form>
            <select ref="schema"></select>
          </form>
        )`

      when 'selecttables'
        tables = goog.array.map @state.data.tables, (table, idx) ->
          `( <p><input type="checkbox" ref={ 'table' + idx } />{table}</p> )` 
        
        `( <form>{tables}</form> )`

  getInitialState: ->
    visible: false
    info: text: '', err: false
    data: null

  render: ->
    title = 'Reengineering dialog'
    buttonSetType = Dialog.buttonSet.OK
    
    if @state.data is null
      text = 'Select database machine that you want to connect'
      confirmHandler = @handleDbConnection
      type = 'dbconnect'
    else if @state.data.schemata?
      text = 'Database contains more than one database schema, select the correct one'
      confirmHandler = @handleSchemaSelect
      type = 'selectschema'
    else if @state.data.tables?
      text = 'Select tables for reengineering'
      confirmHandler = @handleTablesSelected
      type = 'selecttables'


    infoClass = if @state.info.err then 'error' else 'info'
    
    `(
    <Dialog title={title} buttons={buttonSetType} visible={this.state.visible}
      onConfirm={confirmHandler}
     >
      <strong>{text}</strong>

      <div className={infoClass}>{this.state.info.text}</div>

      {this.createContent(type)}
    </Dialog>
    )`
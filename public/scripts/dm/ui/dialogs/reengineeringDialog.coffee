`/** @jsx React.DOM */`

goog.provide 'dm.ui.ReEngineeringDialog'

goog.require 'dm.ui.Dialog'
#goog.require 'goog.array'
goog.require 'goog.object'
goog.require 'dm.ui.Dialog'


dm.ui.ReEngineeringDialog = React.createClass
  show: ->
    @setState visible: true

  hide: ->
    @setState visible: false

  handleError: (err) ->
    @setState info: {text: err, type: 'error'}

  handleDbConnection: ->
    unless @state.data? then return @handleError 'No connection selected'

    {options} = @state.data
    type = options.type

    @props.connection.emit 'connect-db', type, options, (err, data) =>
      if err then @handleError err
      else @setState data: data, info: {text: '', type: null}

    @setState info: {text: 'Trying connect to database', type: 'info'}
    # dont hide dialog until process is complete
    return false

  handleConnSelect: (name, options) ->
    data = null

    if name then data = { name: name, options: options }

    @setState data: data

  handleSchemaSelect: ->


  handleTablesSelected: ->
    selectedTables = []

    @forEachTable (table, name) ->
      if table.checked then selectedTables.push @state.data['tables'][name]

    @props.connection.emit 'get-reeng-data', selectedTables, (err, data) =>
      if err then return @setState info: {text: err, type: 'error'}

      @props.onDataReceive data
      @hide()

  handleCheckAll: (e) ->
    {checked} = e.target

    @forEachTable (table) -> table.checked = checked

  ###*
  * Step over each table in list of table to select and do action defined by
  *  passed function
  *
  * @param {function(Element, string)} fn Function to call with table and its 
  *  name
  ###
  forEachTable: (fn) ->
    goog.object.forEach @refs, ((ref, name) -> 
      fn.call this, ref.getDOMNode(), name.substr(5)
    ), this

  createContent: (type) ->
    switch type
      when 'dbconnect'
        selected = @state.data?.name
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
          <ConnectionsManager conn={this.props.connection} dbTypes={dbTypes}
            selected={selected}
            onError={this.handleError} onSelect={this.handleConnSelect} />
        )`
      when 'selectschema'
        `(
          <form>
            <select ref="schema"></select>
          </form>
        )`

      when 'selecttables'
        tables = goog.array.map @state.data['tables'], (table, idx) ->
          `( <p><input type="checkbox" ref={ 'table' + idx } />{table}</p> )` 
        
        `( 
          <form>
            <p>
              <input type="checkbox" onClick={this.handleCheckAll} />
              Check all tables
            </p>
            <hr />
            {tables}
          </form> )`

  getInitialState: ->
    visible: false
    info: text: '', type: null
    data: null

  render: ->
    {Dialog} = dm.ui
    title = 'Reengineering dialog'
    buttonSetType = Dialog.buttonSet.OK
    
    if not @state.data? or @state.data.name?
      text = 'Select existing database connection or create new'
      confirmHandler = @handleDbConnection
      type = 'dbconnect'
    else if @state.data['schemata']?
      text = 'Database contains more than one database schema, select the correct one'
      confirmHandler = @handleSchemaSelect
      type = 'selectschema'
    else if @state.data['tables']?
      text = 'Select tables for reengineering'
      confirmHandler = @handleTablesSelected
      type = 'selecttables'


    infoClass = 'state'
    infoClass += " #{@state.info.type}" if @state.info.type?
    
    `(
    <Dialog title={title} buttons={buttonSetType} visible={this.state.visible}
      onConfirm={confirmHandler}
     >
      <strong>{text}</strong>

      <div className={infoClass}>{this.state.info.text}</div>

      {this.createContent(type)}
    </Dialog>
    )`

ConnectionsManager = React.createClass
  onChange: (e) ->


  addConnection: (ev) ->
    ev.preventDefault()

    connName = @refs['name'].getDOMNode().value

    if @state.connections[connName]?
      @props.onError 'Connection with this name already exists'

    type = @refs['dbtype'].getDOMNode().value
    pass = @refs['pass'].getDOMNode().value
    port = @refs['port'].getDOMNode().value
    connectOptions =
      'type': type
      'host': @refs['host'].getDOMNode().value
      'db': @refs['db'].getDOMNode().value
      'user': @refs['user'].getDOMNode().value
      'pass': if pass is '' then null else pass
      'port': if port is '' then null else port

    @props.conn.emit 'add-connection', connName, connectOptions, (err) =>
      if err then return @props.onError err

      connections = @state.connections
      connections[connName] = connectOptions

      @setState connections: connections
      @onConnectionSelect connName

  ###*
  * @param {string} selected Name of newly selected connection, if passed it
  * is used instead of getting it from DOM
  ###
  onConnectionSelect: (selected) ->
    selected = @refs['connections'].getDOMNode().value unless goog.isString selected

    if selected is 'placeholder' then selected = null

    @props.onSelect selected, @state.connections[selected]

  createSelect: ->
    options = [`( <option value="placeholder" key="plchldr">---</option> )`]

    goog.object.forEach @state.connections, (conn, name) ->
      options.push `( <option value={name} key={name}>{name}</option> )`

    `( 
      <select ref="connections" onChange={this.onConnectionSelect} 
        value={this.props.selected}>{options}</select> 
    )`

  componentWillMount: ->
    @props.conn.emit 'get-connections', (err, connections) =>
      if err then return @props.onError err
      @setState connections: connections

  getInitialState: ->
    connections: {}

  render: ->
    fieldStyle = 'float': 'right'
    connName = @props.selected
    disabled = connName?

    conn = @state.connections[connName] ? {
      'host': null, 'db': null
      'user': null, 'pass': null
      'port': null, 'type': null
    }

    `(
    <div>
      {this.createSelect()}
      <form>
        <p>
          Connection name
          <input ref="name" style={fieldStyle} value={connName} 
          disabled={disabled} />
        </p>
        <p>
          Database type
          <select ref="dbtype" style={fieldStyle} value={conn['type']} 
            disabled={disabled}>
            {this.props.dbTypes}
          </select>
        </p>
        <p>
          Hostname or Ip address
          <input ref="host" style={fieldStyle} value={conn['host']}
            disabled={disabled} />
        </p>
        <p>
          Database name
          <input ref="db" style={fieldStyle} value={conn['db']} 
            disabled={disabled} />
        </p>
        <p>
          Name of database user
          <input ref="user" style={fieldStyle} value={conn['user']} 
            disabled={disabled} />
        </p>
        <p>
          User password
          <input type="password" ref="pass" style={fieldStyle} 
            value={conn['pass']} disabled={disabled} />
        </p>
        <p>
          Connection port
          <input ref="port" style={fieldStyle} maxLength="5" size="10" value={conn['port']} disabled={disabled} />
        </p>
        <button onClick={this.addConnection} disabled={disabled}>
          Create
        </button>
      </form>
    </div>
    )`
`/** @jsx React.DOM */`

goog.provide 'dm.ui.SelectDbDialog'

goog.require 'dm.ui.Dialog'
goog.require 'goog.net.XhrIo'
goog.require 'goog.events'

{Dialog} = dm.ui

dm.ui.SelectDbDialog = React.createClass
  handleDbSelect: ->
    xhr = new goog.net.XhrIo()

    xhr.send '/', 'POST', "db=#{@state.selectedDb}"
    
    goog.events.listen xhr, [
      goog.net.EventType.SUCCESS, goog.net.EventType.ERROR
    ], @onSetDbComplete

    # dont hide dialog now, it will be hidden when database info load
    return false

  onSetDbComplete: (e) ->
    xhr = (`/** @type {goog.net.xhr} */`) e.target
    
    try
      if e.type is goog.net.EventType.ERROR
        throw new Error xhr.getLastError() + ': ' + xhr.getResponseText()

      @props.onDatabaseSelect xhr.getResponseJson()
      @setState visible: false
    catch e
      @setState info: {text: e.message, err: true}

    xhr.removeAllListeners()
    xhr.dispose()

  setSelectedDb: (ev) ->
    @setState selectedDb: ev.target.value

  getInitialState: ->
    visible: false
    info: text: '', err: false
    selectedDb: @props.dbs[0]?.id 

  render: ->
    title = 'Select database to work with'
    buttonSetType = Dialog.buttonSet.SELECT

    infoClass = if @state.info.err then 'error' else 'info'
    
    selectedDb = @state.selectedDb
    dbsList = @props.dbs.map (db) ->
      `( <option key={db.id} value={db.id}>{db.title}</option> )`

    `(
    <Dialog title={title} buttons={buttonSetType} visible={this.state.visible}
      onConfirm={this.handleDbSelect}
     >
      <strong>List of databases</strong>

      <div className={infoClass}>{this.state.info.text}</div>

      <select defaultValue={selectedDb} onChange={this.setSelectedDb} >{dbsList}
      </select>
    </Dialog>
    )`
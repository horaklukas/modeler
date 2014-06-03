`/** @jsx React.DOM */`

goog.provide 'dm.ui.SelectDbDialog'

goog.require 'dm.ui.Dialog'
goog.require 'goog.net.XhrIo'
goog.require 'goog.events'
goog.require 'goog.object'

{Dialog} = dm.ui

dm.ui.SelectDbDialog = React.createClass
  show: (cb) ->
    if cb? then @setProps onSelect: cb
    @setState visible: true

  handleDbSelect: ->
    @props.onSelect? @refs.selectedDb.getDOMNode().value
    @setState visible: false

  getInitialState: ->
    visible: false
    info: text: '', err: false

  render: ->
    title = 'Select database to work with'
    buttonSetType = Dialog.buttonSet.SELECT
    dbsList = []

    infoClass = if @state.info.err then 'error' else 'info'
    
    goog.object.forEach @props.dbs, (db, id) ->
      dbsList.push(
        `( <option key={id} value={id}>{db.name} - {db.version}</option> )`
      )

    `(
    <Dialog title={title} buttons={buttonSetType} visible={this.state.visible}
      onConfirm={this.handleDbSelect}
     >
      <strong>List of databases</strong>

      <div className={infoClass}>{this.state.info.text}</div>

      <select ref="selectedDb">{dbsList}</select>
    </Dialog>
    )`
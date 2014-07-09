`/** @jsx React.DOM */`

goog.provide 'dm.ui.VersioningDialog'

goog.require 'dm.ui.Dialog'
#goog.require 'goog.array'
goog.require 'goog.object'
goog.require 'dm.ui.Dialog'


dm.ui.VersioningDialog = React.createClass
  show: ->
    @setState visible: true

  hide: ->
    @setState visible: false

  handleRepositorySelect: () ->

  createContent: (type) ->

  getInitialState: ->
    visible: false
    data: {}
    info: err: false, text: ''
    cancelEnabled: true

  render: ->
    {Dialog} = dm.ui
    title = 'Versioning dialog'
    if @state.cancelEnabled then buttonSetType =  Dialog.buttonSet.OK_CANCEL
    else buttonSetType =  Dialog.buttonSet.OK
    
    if @state.data.model?
      if @state.data.repo and @state.data.version
        text = 'Fill information about new version'
        confirmHandler = @handleAddVersion
        type = 'addversion'        
      else
        text = 'Fill information about new repository'
        confirmHandler = @handleAddRepo
        type = 'addrepo'
    else if @state.data.repos?
      text = 'Select your repository'
      confirmHandler = @handleRepositorySelect
      type = 'selectrepo'
    else if @state.data.versions?
      text = 'Select target version'
      confirmHandler = @handleVersionSelect
      type = 'selectversion'
    

    infoClass = 'info'
    infoClass += ' error' if @state.info.err
    
    `(
    <Dialog title={title} buttons={buttonSetType} visible={this.state.visible}
      onConfirm={confirmHandler}
     >
      <strong>{text}</strong>

      <div className={infoClass}>{this.state.info.text}</div>

      {this.createContent(type)}
    </Dialog>
    )`
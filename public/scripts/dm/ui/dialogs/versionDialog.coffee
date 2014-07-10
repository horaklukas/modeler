`/** @jsx React.DOM */`

goog.provide 'dm.ui.VersioningDialog'

goog.require 'dm.ui.Dialog'
goog.require 'goog.array'
goog.require 'goog.object'
goog.require 'dm.ui.Dialog'


dm.ui.VersioningDialog = React.createClass
  show: (data = {}, successCb, cancelCb = ->)->
    @setProps confirmCb: successCb, cancelCb: cancelCb
    @setState {
      data: data
      visible: true
      selectedRepo: null
    }

  hide: ->
    @setState visible: false

  handleCancel: ->
    @hide()
    @props.cancelCb?()

  handleRepositoryConfirm: ({target}) ->
    repo = @state.repos[target.getAttribute('name')]
    
    if not repo?
      @setStatus 'Cannot confirm when repo isnt selected'
    else
      @props.connection.emit 'read-repo', repo, (err, data) =>
        if err then @setStatus err
        else 
          @setState {
            info: {type: null, text: ''}
            data: {versions: data}
            selectedRepo: repo
          }

  handleVersionSelect: ({target}) ->
    repo = @state.selectedRepo
    vers = @state.data.versions[target.getAttribute('name')]

    if not vers?
      @setStatus 'Cannot confirm when version isnt selected'
    else
      @props.connection.emit 'get-version', repo, vers, (err, data) =>
        if err then @setStatus err
        else @props.confirmCb?(data)

  handleAddRepo: ->
    repoName = @refs.repoName.getDOMNode().value
    versName = @refs.versionName.getDOMNode().value
    missing = null

    unless repoName then missing = 'repository'
    else if not versName then missing = 'version'

    if missing? then @setStatus "Please type #{missing} name"
    else @addVersion repoName, @state.data.model

  ###*
  * @param {string} repo Name of repository
  * @param {Object} 
  ###
  addVersion: (repo, data) ->
    @props.connection.emit 'add-version', repo, data, (err, data) ->
      if err then @setStatus err else @props?.confirmCb()

  ###*
  * @param {string} text Text of status
  * @param {string} type Type of status, default is `error`, other options are 
  *  `warning` and `info`
  ###
  setStatus: (text, type = 'error') ->
    @setState info: {type: type, text: text} 

  createContent: (type) ->
    switch type
      when 'selectrepo'
        reposList = goog.array.map @state.repos, (repo, i) ->
          `( <div className="list-item" key={repo+i} name={i} 
              onClick={this.handleRepositoryConfirm}>{repo}</div> )`
        , this
        
        if reposList.length is 0 then reposList = 'There are no repos'

        `( <div>{reposList}</div> )`

      when 'selectversion'
        versionsList = goog.array.map @state.data.versions, (vers, i) ->
          `( <div className="list-item" key={vers+i} name={i}
              onClick={this.handleVersionSelect} >{vers}</div> )`
        , this
        
        # this should never haapen
        if versionsList.length is 0 then versionsList = 'There are no versions'

        `( <div>{versionsList}</div> )`

      when 'addrepo'
        `( <div>
            <p>Repository name: <input ref="repoName" /></p>
            <p>Version name: <input ref="versionName" />not used now</p>
          </div> )`
      
      when 'addversion'  then ''

  componentWillMount: ->
    @props.connection.emit 'get-repos', (err, repos) =>
      @setState if err? then @displayStatus(err) else {repos: repos}

  getInitialState: ->
    visible: false
    data: {}
    info: type: null, text: ''
    repos: []
    selectedRepo: null

  render: ->
    {Dialog} = dm.ui
    title = 'Versioning dialog'
    buttonSet =  Dialog.buttonSet.OK_CANCEL
    
    if @state.data.model?
      if @state.data.repo and @state.data.version
        text = 'Fill information about new version'
        confirmHandler = @handleAddVersion
        type = 'addversion'        
      else
        text = 'Fill information about new repository'
        confirmHandler = @handleAddRepo
        type = 'addrepo'
    else if @state.data.versions?
      text = 'Select target version'
      confirmHandler = @handleVersionSelect
      type = 'selectversion'
      buttonSet = Dialog.buttonSet.CANCEL
    else
      text = 'Select your repository'
      confirmHandler = @handleRepositoryConfirm
      type = 'selectrepo'
      # repository are selected by click on repo, so only Cancel is available
      buttonSet = Dialog.buttonSet.CANCEL
    

    infoClass = 'state'
    infoClass += " #{@state.info.type}" if @state.info.type?
    
    `(
    <Dialog title={title} buttons={buttonSet} visible={this.state.visible}
      onConfirm={confirmHandler} onCancel={this.handleCancel}
     >
      <strong>{text}</strong>

      <div className={infoClass}>{this.state.info.text}</div>

      {this.createContent(type)}
    </Dialog>
    )`
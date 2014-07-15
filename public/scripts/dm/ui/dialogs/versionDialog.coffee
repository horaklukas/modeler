`/** @jsx React.DOM */`

goog.provide 'dm.ui.VersioningDialog'

goog.require 'dm.ui.Dialog'
goog.require 'goog.array'
goog.require 'goog.object'
goog.require 'dm.ui.Dialog'
goog.require 'dm.ui.utils'

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

  handleVersionSelect: (ev) ->
    repo = @state.selectedRepo
    vers = @state.data.versions[ev.currentTarget.getAttribute('name')]

    if not vers?
      return @setStatus 'Cannot confirm when version isnt selected'
    
    @props.connection.emit 'get-version', repo, vers.date, (err, data) =>
      if err then return @setStatus err
      
      @hide() 
      @props.confirmCb?(data['model'], repo, vers.date)

  ###*
  * Handler for create of version at non-existing repo
  ###
  handleAddRepo: ->
    repoName = @refs['repoName'].getDOMNode().value
    versDescr = @refs['versionDescr'].getDOMNode().value

    unless repoName then @setStatus "Please type repository name"
    else @addVersion repoName, @state.data.model, versDescr

  ###*
  * Handler for create of version at existing repo
  ###
  handleAddVersion: ->
    versDescr = @refs['versionDescr'].getDOMNode().value
    @addVersion @state.data.repo, @state.data.model, versDescr

  ###*
  * @param {string} repo Name of repository
  * @param {Object} model 
  * @param {string=} descr Version description 
  ###
  addVersion: (repo, model, descr) ->
    data = goog.object.clone model
    data['descr'] = descr

    @props.connection.emit 'add-version', repo, data, (err, data) =>
      if err then @setStatus err else @props?.confirmCb repo

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
          date = vers['date']
          descr = vers['descr']
          `( <div className="list-item" key={date+i} name={i}
              onClick={this.handleVersionSelect} 
             >
              {dm.ui.utils.convertMsToDateTimeFormat(date)}{' '}{descr}
             </div> 
           )`
        , this
        
        # this should never haapen
        if versionsList.length is 0 then versionsList = 'There are no versions'

        `( <div>{versionsList}</div> )`

      when 'addrepo'
        `( <div>
            <p>Repository name: <input ref="repoName" /></p>
            <p>Version description: <input ref="versionDescr" /></p>
          </div> )`
      
      when 'addversion'
        `( <div>
            <p>Version description: <input ref="versionDescr" /></p>
          </div> )`

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
      if @state.data.repo
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

    repo = @state.selectedRepo ? @state.data.repo ? null
    additionalInfo = `(<p>Repository: <strong>{repo}</strong></p>)` if repo?

    infoClass = 'state'
    infoClass += " #{@state.info.type}" if @state.info.type?
    
    `(
    <Dialog title={title} buttons={buttonSet} visible={this.state.visible}
      onConfirm={confirmHandler} onCancel={this.handleCancel}
     >

      {additionalInfo}
      <strong>{text}</strong>

      <div className={infoClass}>{this.state.info.text}</div>

      {this.createContent(type)}
    </Dialog>
    )`
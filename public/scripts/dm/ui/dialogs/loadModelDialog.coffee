`/** @jsx React.DOM */`

goog.provide 'dm.ui.LoadModelDialog'

goog.require 'goog.net.IframeIo'
goog.require 'goog.events'
goog.require 'dm.ui.Dialog'


dm.ui.LoadModelDialog = React.createClass
  ###*
  * Show the dialog
  ###
  show: (cancelCb = ->) ->
    @setProps cancelCb: cancelCb
    @setState
      visible: true
      info: text: '', type: null

  hide: ->
    @setState visible: false

  onCancel: ->
    @hide()
    @props.cancelCb?()

  onUploadRequest: (e) ->
    e.preventDefault()
    form = (`/** @type {HTMLFormElement} */`) e.target

    iFrameIo = new goog.net.IframeIo()

    iFrameIo.sendFromForm(form)

    goog.events.listen iFrameIo, [
      goog.net.EventType.SUCCESS, goog.net.EventType.ERROR
    ], @onUploadComplete

  onUploadComplete: (e) ->
    iFrameIo = (`/** @type {goog.net.IframeIo} */`) e.target

    try
      if e.type is goog.net.EventType.ERROR
        throw new Error iFrameIo.getLastError()

      @props.onModelLoad iFrameIo.getResponseJson()
      @hide()
    catch e
      @setState info: {text: e.message, type: 'error'}

    iFrameIo.removeAllListeners()
    iFrameIo.dispose()

  onFileChange: ->
    @setState loadDisabled: false

  getInitialState: ->
    visible: false
    info: text: '', type: null
    loadDisabled: true

  render: ->
    {Dialog} = dm.ui
    {visible, info, loadDisabled} = @state
    title = 'Load model from file'
    infoClasses = 'state' + (if info.type? then " #{info.type}" else '')

    buttonSet = dm.ui.Dialog.buttonSet.CANCEL

    `(
    <Dialog title={title} onCancel={this.onCancel} visible={visible}
      buttons={buttonSet} >

      <form method="POST" action="/load" encType="multipart/form-data"
        onSubmit={this.onUploadRequest}>
        <div className={infoClasses}>{this.state.info.text}</div>

        <p>Select JSON that contains model:</p>

        <p>
          <input type="file" name="modelfile" onChange={this.onFileChange} />
          <input type="submit" name="load" value="Load model"
            disabled={loadDisabled} />
        </p>
      </form>
    </Dialog>
    )`

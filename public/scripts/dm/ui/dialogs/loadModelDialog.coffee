`/** @jsx React.DOM */`

goog.provide 'dm.ui.LoadModelDialog'

goog.require 'goog.net.IframeIo'
goog.require 'goog.events'

{Dialog} = dm.ui

dm.ui.LoadModelDialog = React.createClass
	###*
  * Show the dialog
	###
	show: ->
		@setState 
			visible: true
			info: text: '', type: null 

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
			@setState visible: false
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
    {visible, info, loadDisabled} = @state
    title = 'Load model from file'
    infoClasses = 'info' + (if info.type? then " #{info.type}" else '')

    `(
    <Dialog title={title} onConfirm={this.onConfirm} visible={visible} 
    	buttons={dm.ui.Dialog.buttonSet.CANCEL} >

      <form method="POST" action="/load" encType="multipart/form-data"
      	onSubmit={this.onUploadRequest}>
				<p className={infoClasses}>{this.state.info.text}</p>

				<p>Select JSON that contains model:</p>

				<p>
					<input type="file" name="modelfile" onChange={this.onFileChange} />
					<input type="submit" name="load" value="Load model" 
						disabled={loadDisabled} />
				</p>
			</form>
    </Dialog>
    )`

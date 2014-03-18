goog.provide 'dm.dialogs.LoadModelDialog'

goog.require 'goog.ui.Dialog'
goog.require 'goog.net.IframeIo'
goog.require 'goog.events'
goog.require 'goog.events.Event'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'tmpls.dialogs.loadModel'

class dm.dialogs.LoadModelDialog extends goog.ui.Dialog
	@EventType =
		CONFIRM: goog.events.getUniqueId 'dialog-confirmed'

	constructor: () ->
		super()

		@setTitle 'Load model from file'
		@setButtonSet null #goog.ui.Dialog.ButtonSet.OK_CANCEL
		@setDraggable false

		# force render dialog, so all control widgets exists since now
		#content = @getContentElement()
		

	###*
  * @param {boolean} show
	###
	show: (show) ->
		@setVisible show 

		if show is true
			@setContent tmpls.dialogs.loadModel.dialog()
			
			form = (`/** @type {HTMLFormElement} */`) goog.dom.getElement 'load_model'

			goog.events.listen form, goog.events.EventType.SUBMIT, @onUploadRequest

	onUploadRequest: (e) =>
		e.preventDefault()
		form = (`/** @type {HTMLFormElement} */`) e.target

		iFrameIo = new goog.net.IframeIo()

		iFrameIo.sendFromForm(form)
		
		goog.events.listen iFrameIo, [
			goog.net.EventType.SUCCESS, goog.net.EventType.ERROR
		], @onUploadComplete

	onUploadComplete: (e) =>
		iFrameIo = (`/** @type {goog.net.IframeIo} */`) e.target
		
		try
			if e.type is goog.net.EventType.ERROR
				throw new Error iFrameIo.getLastError()

			@dispatchEvent new ModelLoadedEvent(iFrameIo.getResponseJson())
			@show false
		catch e
			infobar = goog.dom.getElementByClass 'info', @getContentElement()
			goog.dom.setTextContent infobar, e.message
			goog.dom.classes.enable infobar, 'error', true

		iFrameIo.removeAllListeners()
		iFrameIo.dispose()

class ModelLoadedEvent extends goog.events.Event
	###*
  * @param {Object} modelJSON
	###
	constructor: (modelJSON) ->
		super dm.dialogs.LoadModelDialog.EventType.CONFIRM

		###*
    * @type {Object}
		###
		@model = modelJSON
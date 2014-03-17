goog.provide 'dm.dialogs.LoadModelDialog'

goog.require 'goog.ui.Dialog'
goog.require 'goog.net.IframeIo'
goog.require 'goog.events'
goog.require 'tmpls.dialogs.loadModel'

class dm.dialogs.LoadModelDialog extends goog.ui.Dialog
	@EventType =
		CONFIRM: goog.events.getUniqueId 'dialog-confirmed'

	constructor: () ->
		super()

		@setContent tmpls.dialogs.loadModel.dialog()
		@setButtonSet goog.ui.Dialog.ButtonSet.OK_CANCEL
		@setDraggable false

		# force render dialog, so all control widgets exists since now
		content = @getContentElement()
		
		form = (`/** @type {HTMLFormElement} */`) goog.dom.getElement 'load_model'

		goog.events.listen form, goog.events.EventType.SUBMIT, @onUploadRequest

		###
		addBtn = goog.dom.getElementsByTagNameAndClass('button', 'add', content)[0]
		@nameField = goog.dom.getElement 'table_name'
		@colslist = goog.dom.getElement 'columns_list'

		# events 1) add new column 2) delete existing column 3) dialog ok or cancel
		goog.events.listen addBtn, goog.events.EventType.CLICK, @addColumn

		goog.events.listen @colslist, goog.events.EventType.CLICK, (e) =>
			if goog.dom.classes.has e.target, 'delete' then @removeColumn e.target	

		goog.events.listen @, goog.ui.Dialog.EventType.SELECT, @onSelect
		###

	###*
  * @param {boolean} show
	###
	show: (show) ->
		@setVisible show 

	onUploadRequest: (e) =>
		e.preventDefault()
		form = (`/** @type {HTMLFormElement} */`) e.target

		iFrameIo = new goog.net.IframeIo()

		iFrameIo.sendFromForm(form)
		
		goog.events.listen iFrameIo, goog.net.EventType.SUCCESS, @onUploadSuccess
		goog.events.listen iFrameIo, goog.net.EventType.ERROR, @onUploadError

	onUploadSuccess: (e) ->
		iFrameIo = (`/** @type {goog.net.IframeIo} */`) e.target
		
		console.log iFrameIo.getResponseJson()
		iFrameIo.removeAllListeners()
		iFrameIo.dispose()

	onUploadError: (e) ->
		iFrameIo = (`/** @type {goog.net.IframeIo} */`) e.target

		console.warn iFrameIo.getLastError()
		iFrameIo.removeAllListeners()
		iFrameIo.dispose()
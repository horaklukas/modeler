goog.provide 'dm.dialogs.SelectDbDialog'

goog.require 'goog.ui.Dialog'
goog.require 'goog.net.XhrIo'
goog.require 'goog.events'
goog.require 'goog.events.Event'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.dom.forms'
goog.require 'tmpls.dialogs.selectDb'

class dm.dialogs.SelectDbDialog extends goog.ui.Dialog
	@EventType =
		SELECTED: goog.events.getUniqueId 'db-selected'

	constructor: (@dbs) ->
		super()

		@setTitle 'Select database to work with'
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
			@setContent tmpls.dialogs.selectDb.dialog {dbs: @dbs}
			
			form = (`/** @type {HTMLFormElement} */`) goog.dom.getElement 'select_db'

			goog.events.listen form, goog.events.EventType.SUBMIT, @onSelectRequest

	onSelectRequest: (e) =>
		e.preventDefault()
		form = (`/** @type {HTMLFormElement} */`) e.target

		xhr = new goog.net.XhrIo()

		xhr.send '/', 'POST', goog.dom.forms.getFormDataString(form)
		
		goog.events.listen xhr, [
			goog.net.EventType.SUCCESS, goog.net.EventType.ERROR
		], @onSetDbComplete

	onSetDbComplete: (e) =>
		xhr = (`/** @type {goog.net.xhr} */`) e.target
		
		try
			if e.type is goog.net.EventType.ERROR
				throw new Error xhr.getLastError() + ': ' + xhr.getResponseText()

			@dispatchEvent new DbSelectedEvent(xhr.getResponseJson())
			xhr.getResponseJson()
			@show false
		catch e
			infobar = goog.dom.getElementByClass 'info', @getContentElement()
			goog.dom.setTextContent infobar, e.message
			goog.dom.classes.enable infobar, 'error', true

		xhr.removeAllListeners()
		xhr.dispose()

class DbSelectedEvent extends goog.events.Event
	###*
  * @param {Object} dbData
	###
	constructor: (dbData) ->
		super dm.dialogs.SelectDbDialog.EventType.SELECTED

		###*
    * @type {Object}
		###
		@assets = dbData
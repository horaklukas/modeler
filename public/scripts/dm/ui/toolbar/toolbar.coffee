goog.provide 'dm.ui.Toolbar'
goog.provide 'dm.ui.Toolbar.EventType'

goog.require 'dm.ui.Canvas'
goog.require 'dm.ui.tools.CreateTable'
goog.require 'dm.ui.tools.CreateRelation'
goog.require 'dm.ui.tools.SimpleCommandButton'
goog.require 'goog.events'
goog.require 'goog.events.Event'
goog.require 'goog.ui.Toolbar'
#goog.require 'goog.ui.ToolbarMenuButton'
#goog.require 'goog.ui.ToolbarSelect'
goog.require 'goog.ui.ToolbarSeparator'
goog.require 'goog.ui.SelectionModel'
goog.require 'goog.dom'
goog.require 'goog.style'

class dm.ui.Toolbar extends goog.ui.Toolbar
	@EventType =
		CREATE: goog.events.getUniqueId 'object-created'
		GENERATE_SQL: goog.events.getUniqueId 'generate-sql'
		SAVE_MODEL: goog.events.getUniqueId 'save-model'
		LOAD_MODEL: goog.events.getUniqueId 'load-model'
		EXPORT_MODEL: goog.events.getUniqueId 'export-model'
		STATUS_CHANGE: goog.events.getUniqueId 'status-change'

	###*
  * @constructor
  * @extends {goog.ui.Toolbar}
	###
	constructor: ->
		super()

		@selectionModel_ = new goog.ui.SelectionModel()
		@selectionModel_.setSelectionHandler @onSelect

		###*
    * @type {Element}
		###
		@statusBar_ = null

	###* @override	###
	createDom: ->
		super()

		domHelper = @getDomHelper()

		@statusBar_ = domHelper.createDom(
			'div', 'statusbar goog-inline-block', [
				domHelper.createDom('span', 'model-saved')
				domHelper.createDom('span', 'model-name') 
				domHelper.createDom('span', 'db-version') 
			]
		)
		goog.dom.appendChild @getContentElement(), @statusBar_

	###* @override  ###
	enterDocument: ->
		super()
		canvas = dm.ui.Canvas.getInstance()
		
		@selectionModel_.addItem @getChildAt 0
		@selectionModel_.addItem @getChildAt 1
		@selectionModel_.addItem @getChildAt 2

		goog.events.listen this, goog.ui.Component.EventType.ACTION, (e) =>
			tool = e.target

			if @selectionModel_.indexOfItem(tool) > -1
				if @selectionModel_.getSelectedItem() is tool
					@selectionModel_.setSelectedItem()
					tool.cancel()
				else 
					@selectionModel_.setSelectedItem tool
			else
				tool.startAction()

		goog.events.listen canvas, dm.ui.Canvas.EventType.CLICK, (ev) =>
			selectedButton = @selectionModel_.getSelectedItem()
			unless selectedButton then return false
			
			if selectedButton.setActionEvent ev
				@selectionModel_.setSelectedItem() # reset selected tool

		goog.events.listen(
			goog.dom.getElementByClass('model-name', @statusBar_)
			goog.events.EventType.DBLCLICK
			(ev) =>
				@dispatchEvent dm.ui.Toolbar.EventType.STATUS_CHANGE 
		)

	###*
  * @param {goog.ui.Button} button
  * @param {boolean} select
	###
	onSelect: (button, select) ->
		if button then button.setChecked select

		if select is true then button.startAction()
		else if select is false then button.finishAction()

	###*
  * @param {?string} model Name of actual model
  * @param {?string=} db Name of actual database
  * @param {?boolean=} saved Determine saved/unsaved status
	###
	setStatus: (model, db, saved) =>
		if model? 
			goog.dom.setTextContent(
				goog.dom.getElementByClass('model-name', @statusBar_), model
			)

		if db?
			goog.dom.setTextContent(
				goog.dom.getElementByClass('db-version', @statusBar_), db
			)

		if saved?
			statusSaved = goog.dom.getElementByClass 'model-saved', @statusBar_

			if saved is true then mark = '✓'; color = 'green'; title = 'Model saved'
			else mark = '✗'; color = 'red'; title = 'Model is at unsaved state'

			goog.dom.setTextContent statusSaved, mark
			goog.dom.setProperties statusSaved, {'title': title}
			goog.style.setStyle statusSaved, 'color', color

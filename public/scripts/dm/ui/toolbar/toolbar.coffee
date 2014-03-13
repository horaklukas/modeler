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
#goog.require 'goog.ui.ToolbarSeparator'
goog.require 'goog.ui.SelectionModel'


class dm.ui.Toolbar extends goog.ui.Toolbar
	@EventType =
		CREATE: goog.events.getUniqueId 'object-created'
		GENERATE_SQL: goog.events.getUniqueId 'generate-sql'
		SAVE_MODEL: goog.events.getUniqueId 'save-model'

	###*
  * @constructor
  * @extends {goog.ui.Toolbar}
	###
	constructor: ->
		super()

		@selectionModel_ = new goog.ui.SelectionModel()
		@selectionModel_.setSelectionHandler @onSelect

	###* @override	###
	createDom: ->
		super()

		@addChild new dm.ui.tools.CreateTable, true
		@addChild new dm.ui.tools.CreateRelation(true), true
		@addChild new dm.ui.tools.CreateRelation(false), true
		@addChild new dm.ui.tools.SimpleCommandButton(
			'generate-sql', dm.ui.Toolbar.EventType.GENERATE_SQL
		), true
		@addChild new dm.ui.tools.SimpleCommandButton(
			'save-model', dm.ui.Toolbar.EventType.SAVE_MODEL
		), true
		@addChild

	###* @override  ###
	enterDocument: ->
		super()
		canvas = dm.ui.Canvas.getInstance()
		
		@selectionModel_.addItem @getChildAt 0
		@selectionModel_.addItem @getChildAt 1
		@selectionModel_.addItem @getChildAt 2

		goog.events.listen this, goog.ui.Component.EventType.ACTION, (e) =>
			if @selectionModel_.indexOfItem(e.target) > -1
				@selectionModel_.setSelectedItem e.target
			else
				@selectionModel_.setSelectedItem()
				e.target.startAction()

		goog.events.listen canvas, dm.ui.Canvas.EventType.CLICK, (ev) =>
			selectedButton = @selectionModel_.getSelectedItem()
			unless selectedButton then return false
			
			if selectedButton.setActionEvent ev
				@selectionModel_.setSelectedItem() # reset selected tool

	###*
  * @param {goog.ui.Button} button
  * @param {boolean} select
	###
	onSelect: (button, select) ->
		if button then button.setChecked select

		if select is true then button.startAction()
		else if select is false then button.finishAction()




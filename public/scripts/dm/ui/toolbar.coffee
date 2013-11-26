goog.provide 'dm.ui.Toolbar'
goog.provide 'dm.ui.tools.CreateTable'
goog.provide 'dm.ui.tools.createRelation'

goog.require 'dm.ui.Canvas'
goog.require 'dm.dialogs.TableDialog'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.events'
goog.require 'goog.events.EventType'
goog.require 'goog.events.EventTarget'
goog.require 'goog.style'

goog.require 'goog.ui.Component.State'
goog.require 'goog.ui.Component.EventType'
goog.require 'goog.ui.Toolbar'
#goog.require 'goog.ui.ToolbarButton'
#goog.require 'goog.ui.ToolbarMenuButton'
#goog.require 'goog.ui.ToolbarSelect'
#goog.require 'goog.ui.ToolbarSeparator'
goog.require 'goog.ui.ToolbarToggleButton'
goog.require 'goog.ui.SelectionModel'

class dm.ui.Toolbar extends goog.ui.Toolbar
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

		@addChild new dm.ui.tools.CreateTable(), true
		@addChild new dm.ui.tools.CreateRelation(), true

	###* @override  ###
	enterDocument: ->
		super()
		canvas = dm.ui.Canvas.getInstance()
		
		@selectionModel_.addItem @getChildAt 0
		@selectionModel_.addItem @getChildAt 1

		goog.events.listen this, goog.ui.Component.EventType.ACTION, (e) =>
				@selectionModel_.setSelectedItem e.target
              
		goog.events.listen canvas, dm.ui.Canvas.EventType.CLICK, (ev) =>
			selectedButton = @selectionModel_.getSelectedItem()
			unless selectedButton then return false
			
			selectedButton.setActionEvent ev
			@selectionModel_.setSelectedItem() # reset selected tool

	###*
  * @param {goog.ui.Button} button
  * @param {boolean} select
	###
	onSelect: (button, select) ->
		if button then button.setChecked select

		if select is true then button.startAction()
		else if select is false then button.finishAction()

class dm.ui.tools.CreateToggleButton extends goog.ui.ToolbarToggleButton
	###*
  * @constructor
  * @extends {goog.ui.ToolbarToggleButton}
	###	
	constructor: (name) ->
		super goog.dom.createDom 'div', "icon tool create-#{name}"

		@setAutoStates goog.ui.Component.State.CHECKED, false

	###*
  * @param {dm.ui.Canvas.Click} ev Click on canvas event
	###
	setActionEvent: (ev) ->
		@actionEvent = ev
	
class dm.ui.tools.CreateTable extends dm.ui.tools.CreateToggleButton
	###*
  * @constructor
  * @extends {dm.ui.tools.CreateToggleButton}
	###	
	constructor: ->
		super 'table'

		###*
    * @type {?goog.events.Event}
		###
		@actionEvent = null

	###*
  * Called by toolbar when tool is selected
	###
	startAction: ->
		canvas = dm.ui.Canvas.getInstance()
		goog.style.showElement canvas.clueTable, true 
		
		# When moving over canvas, show blind table as clue
		canvas.move = 
			offset: new goog.math.Coordinate 0, 0
			object: canvas.clueTable

		goog.style.setPosition canvas.clueTable, 0, 0
		goog.events.listen document, goog.events.EventType.MOUSEMOVE, canvas.moveTable

	###*
	###
	finishAction: (ev) =>
		canvas = dm.ui.Canvas.getInstance()
		goog.style.showElement canvas.clueTable, false

		# deactivate all events
		goog.events.unlisten document, goog.events.EventType.MOUSEMOVE, canvas.moveTable

		# tool action finished correctly, create new table
		if @actionEvent?
			tab = new dm.ui.Table(
				new dm.model.Table(), @actionEvent.position.x, @actionEvent.position.y
			)
			canvas.addChild tab, true
			
		if tab? then dm.dialogs.TableDialog.getInstance().show true, tab
		@actionEvent = null


class dm.ui.tools.CreateRelation extends dm.ui.tools.CreateToggleButton
	###*
  * @constructor
  * @extends {dm.ui.tools.CreateToggleButton}
	###
	constructor: ->
		super 'relation'

	startAction: ->
		canvas = dm.ui.Canvas.getInstance()
		canvas.html.style.cursor = 'crosshair'

	###*
  * @param {goog.math.Coordinate=} position
  * @param {?HTMLElement} object
	###
	finishAction: (position, object) ->
		unless position then return true 
		unless object then return false

		canvas = dm.ui.Canvas.getInstance()
		mousemove = goog.events.EventType.MOUSEMOVE

		# Create clue relation or only set start point to existing
		unless canvas.startRelationPath
			@startTabId = object.id
			canvas.setStartRelationPoint position
			goog.events.listen canvas.html, mousemove, canvas.moveEndRelationPoint

			return false
		else
			canvas.placeRelation position, @startTabId, object.id
			goog.events.unlisten canvas.html, mousemove, canvas.moveEndRelationPoint

			canvas.html.style.cursor = 'default'
			return true
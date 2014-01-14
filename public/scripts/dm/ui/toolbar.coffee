goog.provide 'dm.ui.Toolbar'
goog.provide 'dm.ui.Toolbar.EventType'
goog.provide 'dm.ui.tools.CreateTable'
goog.provide 'dm.ui.tools.CreateRelation'

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
	@EventType:
		CREATE: goog.events.getUniqueId 'object-created'

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

class dm.ui.tools.CreateToggleButton extends goog.ui.ToolbarToggleButton
	###*
  * @constructor
  * @extends {goog.ui.ToolbarToggleButton}
	###	
	constructor: (name) ->
		super goog.dom.createDom 'div', "icon tool create-#{name}"

		@setAutoStates goog.ui.Component.State.CHECKED, false

		###*
    * @type {?goog.events.Event}
		###
		@actionEvent = null

	###*
  * @param {dm.ui.Canvas.Click} ev Click on canvas event
  * @return {boolean} true if setting action succeded
	###
	setActionEvent: (ev) ->
		@actionEvent = ev
		return true
	
class dm.ui.tools.CreateTable extends dm.ui.tools.CreateToggleButton
	###*
  * @constructor
  * @extends {dm.ui.tools.CreateToggleButton}
	###	
	constructor: ->
		super 'table'

		canvas = dm.ui.Canvas.getInstance()

		@table = canvas.clueTable
		@tabSize = goog.style.getSize canvas.clueTable 

		@areaSize = canvas.getSize()

	###*
  * Called by toolbar when tool is selected
	###
	startAction: ->
		# When moving over canvas, show blind table as a clue
		goog.style.showElement @table, true 
		goog.style.setPosition @table, 0, 0
		goog.events.listen document, goog.events.EventType.MOUSEMOVE, @moveTable

	###*
  * @param {goog.events.Event} ev Clue table move event
	###
	moveTable: (ev) =>
		{x, y} = goog.style.getRelativePosition(
			ev, goog.style.getOffsetParent @table
		)

		if x + @tabSize.width > @areaSize.width
			x = @areaSize.width - @tabSize.width - 2
		else if x < 0 then x = 0

		if y + @tabSize.height > @areaSize.height
			y = @areaSize.height - @tabSize.height - 2
		else if y < 0 then y = 0

		goog.style.setPosition @table, x, y

	###*
	###
	finishAction: =>
		canvas = dm.ui.Canvas.getInstance()
		goog.style.showElement canvas.clueTable, false

		# deactivate all events
		goog.events.unlisten document, goog.events.EventType.MOUSEMOVE, @moveTable

		# tool action finished correctly, create new table
		if @actionEvent?
			@dispatchEvent new dm.ui.Toolbar.ObjectCreate(
				'table', @actionEvent.position
			)
			
		@actionEvent = null


class dm.ui.tools.CreateRelation extends dm.ui.tools.CreateToggleButton
	###*
  * @constructor
  * @extends {dm.ui.tools.CreateToggleButton}
	###
	constructor: ->
		super 'relation'

		###*
    * @type {dm.ui.Table}
		###
		@parentTable = null

		###*
    * @type {dm.ui.Table}
		###
		@childTable = null

	startAction: ->
		canvas = dm.ui.Canvas.getInstance()
		#goog.style.setStyle canvas.getElement(), 'cursor', 'pointer'
		#canvas..style.cursor = 'pointer'

	###*
  * @param {dm.ui.Canvas.Click} ev Click on canvas event
	###
	setActionEvent: (ev) ->
		obj = ev.target
		if obj instanceof dm.ui.Table
			goog.dom.classes.add obj.getElement(), 'active'

			if not @parentTable? then @parentTable = obj
			else if not @childTable then @childTable = obj; return true

		return false

	###*
  * @param {goog.math.Coordinate=} position
  * @param {?HTMLElement} object
	###
	finishAction: (position, object) ->
		unless (@parentTable and @childTable) then return false
		
		goog.dom.classes.remove @parentTable.getElement(), 'active'
		goog.dom.classes.remove @childTable.getElement(), 'active'

		@dispatchEvent new dm.ui.Toolbar.ObjectCreate(
			'relation', {parent: @parentTable, child: @childTable}
		)

		@parentTable = null
		@childTable = null
		###
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
		###

class dm.ui.Toolbar.ObjectCreate extends goog.events.Event
	###*
  * @param {(goog.math.Coordinate|*)} data Position in canvas where to create
  *  or any other data associated with creation process
  * @constructor
  * @extends {goog.events.Event}
	###
	constructor: (@objType, @data) ->
		super dm.ui.Toolbar.EventType.CREATE
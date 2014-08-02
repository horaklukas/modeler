goog.provide 'dm.ui.tools.CreateTable'

goog.require 'dm.ui.tools.CreateToggleButton'
goog.require 'dm.ui.tools.ObjectCreateEvent'
goog.require 'dm.ui.Canvas'
goog.require 'goog.style'
goog.require 'goog.events'

class dm.ui.tools.CreateTable extends dm.ui.tools.CreateToggleButton
	###*
  * @constructor
  * @extends {dm.ui.tools.CreateToggleButton}
	###	
	constructor: ->
		super 'table', 'Create table'
		@setId 'table'

		canvas = dm.ui.Canvas.getInstance()

		@table = canvas.clueTable
		@tabSize = goog.style.getSize canvas.clueTable 

		@areaSize = canvas.getSize()

	###*
  * Called by toolbar when tool is selected
	###
	startAction: ->
		# When moving over canvas, show blind table as a clue
		goog.style.setElementShown @table, true 
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
		goog.style.setElementShown canvas.clueTable, false

		# deactivate all events
		goog.events.unlisten document, goog.events.EventType.MOUSEMOVE, @moveTable

		# tool action finished correctly, create new table
		if @actionEvent?
			@dispatchEvent new dm.ui.tools.ObjectCreateEvent(
				'table', @actionEvent.position
			)
			
		@actionEvent = null

	cancel: ->
		@actionEvent = null
goog.provide 'dm.ui.ControlPanel'

goog.require 'dm.ui.Canvas'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.events'
goog.require 'goog.events.EventType'
goog.require 'goog.events.EventTarget'
goog.require 'goog.style'

class dm.ui.ControlPanel extends goog.events.EventTarget
	###*
  * @constructor
  * @extends {goog.events.EventTarget}
	###
	constructor: ->
		super()	

	###*
  * @param {!HTMLElement} cp Control panel html element
  ###
	init: (cp) ->
		@obj = cp
		canvas = dm.ui.Canvas.getInstance()

		goog.events.listen @obj, goog.events.EventType.CLICK, @onClicked 
		goog.events.listen canvas, dm.ui.Canvas.EventType.CLICK, (ev) =>
			unless @activeTool then return false
			
			@toolFinished ev.position, ev.object

	###*
  * @param {goog.events.Event} e
	###
	onClicked: (e) =>
		e.stopPropagation()

		if goog.dom.classes.has e.target, 'tool' then @activateTool e.target

	###*
  * @param {!HTMLElement}
	###
	activateTool: (tool) =>
		# End unfinished previously selected tool
		if @activeTool then @toolFinished()

		# Clicked same tool again, ended above, so lets end
		if tool is @activeTool then return false

		@activeTool = tool
		goog.dom.classes.add @activeTool, 'active'

		# Call tool-specific initialization function
		@["#{@activeTool.name}Init"]() 

	###*
  * @param {goog.math.Coordinate=} coord
  * @param {HTMLElement=} object
	###
	toolFinished: (coord, object) =>
		# if tool finish method return false, its action not end yet and should not
		# been deactivated
		unless @["#{@activeTool.name}Finish"](coord, object) then return false

		goog.dom.classes.remove @activeTool, 'active'
		@activeTool = undefined

	createTableInit: ->
		canvas = dm.ui.Canvas.getInstance()

		# When moving over canvas, show blind table as clue
		goog.events.listen canvas.html, goog.events.EventType.MOUSEMOVE, canvas.moveTable

		#goog.events.listen document, goog.events.EventType.CLICK, @toolFinished

	createRelationInit: (ev) ->
		canvas = dm.ui.Canvas.getInstance()
		canvas.html.style.cursor = 'crosshair'		

	###*
  * @param {goog.math.Coordinate=} position
  * @param {HTMLElement=} object
	###
	createTableFinish: (position, object) =>
		canvas = dm.ui.Canvas.getInstance()

		if position then canvas.placeTable position

		# Deactivate all events
		goog.events.unlisten canvas.html, goog.events.EventType.MOUSEMOVE, canvas.moveTable
		#goog.events.unlisten document, goog.events.EventType.CLICK, @toolFinished

	###*
  * @param {goog.math.Coordinate=} position
  * @param {?HTMLElement} object
	###
	createRelationFinish: (position, object) ->
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

goog.addSingletonGetter dm.ui.ControlPanel

if not window? then module.exports = dm.ui.ControlPanel
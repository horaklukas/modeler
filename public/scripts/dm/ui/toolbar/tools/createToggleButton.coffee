goog.provide 'dm.ui.tools.CreateToggleButton'
goog.provide 'dm.ui.tools.ObjectCreateEvent'
goog.provide 'dm.ui.tools.EventType'

goog.require 'goog.dom'
goog.require 'goog.events'
goog.require 'goog.ui.ToolbarToggleButton'
goog.require 'goog.ui.Component.State'

dm.ui.tools.EventType.CREATE = goog.events.getUniqueId 'object-created'

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

class dm.ui.tools.ObjectCreateEvent extends goog.events.Event
	###*
  * @param {(goog.math.Coordinate|*)} data Position in canvas where to create
  *  or any other data associated with creation process
  * @constructor
  * @extends {goog.events.Event}
	###
	constructor: (@objType, @data) ->
		super dm.ui.tools.EventType.CREATE
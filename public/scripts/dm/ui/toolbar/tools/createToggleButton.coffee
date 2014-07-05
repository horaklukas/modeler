goog.provide 'dm.ui.tools.CreateToggleButton'
goog.provide 'dm.ui.tools.ObjectCreateEvent'

goog.require 'goog.dom'
goog.require 'goog.events'
goog.require 'goog.ui.ToolbarToggleButton'
goog.require 'goog.ui.Component.State'


class dm.ui.tools.CreateToggleButton extends goog.ui.ToolbarToggleButton
	###*
  * @constructor
  * @extends {goog.ui.ToolbarToggleButton}
	###	
	constructor: (name, title = '') ->
		super goog.dom.createDom 'div', {
			'class': "icon tool create-#{name}"
			'title': title
		}

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

	###*
  * This method should be owerwritten. It's used to cancel action of selected
  * button
	###
	cancel: goog.abstractMethod

class dm.ui.tools.ObjectCreateEvent extends goog.events.Event
	###*
  * @param {(goog.math.Coordinate|*)} data Position in canvas where to create
  *  or any other data associated with creation process
  * @constructor
  * @extends {goog.events.Event}
	###
	constructor: (@objType, @data) ->
		super dm.ui.Toolbar.EventType.CREATE
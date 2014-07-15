goog.provide 'dm.ui.tools.SimpleCommandButton'

goog.require 'goog.ui.ToolbarButton'

class dm.ui.tools.SimpleCommandButton extends goog.ui.ToolbarButton
	###*
	* @param {!string} cssClass
	* @param {string} event Name of event to be dispatched after click
	* @param {?string=} title Optional content of `title` attribute
	* @param {string=} id Id of tool
  * @constructor
  * @extends {goog.ui.ToolbarButton}
	###	
	constructor: (cssClass, event, title = '', id) ->
		super goog.dom.createDom 'div', {
			'class': "icon tool #{cssClass}"
			'title': title
		}

		if id? then @setId id

		###*
    * @type {string}
		###
		@event = event

	startAction: ->
		@dispatchEvent @event
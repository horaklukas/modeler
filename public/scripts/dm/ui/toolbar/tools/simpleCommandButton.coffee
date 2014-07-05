goog.provide 'dm.ui.tools.SimpleCommandButton'

goog.require 'goog.ui.ToolbarButton'

class dm.ui.tools.SimpleCommandButton extends goog.ui.ToolbarButton
	###*
	* @param {!string} cssClass
	* @param {string} event Name of event to be dispatched after click
  * @constructor
  * @extends {goog.ui.ToolbarButton}
	###	
	constructor: (cssClass, event, title = '') ->
		super goog.dom.createDom 'div', {
			'class': "icon tool #{cssClass}"
			'title': title
		}

		###*
    * @type {string}
		###
		@event = event

	startAction: ->
		@dispatchEvent @event
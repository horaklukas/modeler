goog.provide 'dm.ui.tools.SimpleCommandButton'

goog.require 'goog.ui.ToolbarButton'

class dm.ui.tools.SimpleCommandButton extends goog.ui.ToolbarButton
	###*
	* @param {!string} cssClass
	* @param {string} event Name of event to be dispatched after click
  * @constructor
  * @extends {goog.ui.ToolbarButton}
	###	
	constructor: (cssClass, event) ->
		super goog.dom.createDom 'div', "icon tool #{cssClass}"

		###*
    * @type {string}
		###
		@event = event

	startAction: ->
		@dispatchEvent @event
###
goog.provide 'dm.ui.tools.GenerateSql'

goog.require 'goog.ui.ToolbarButton'
goog.require 'dm.sqlgen.Sql92'

class dm.ui.tools.GenerateSql extends goog.ui.ToolbarButton
###
###*
* @constructor
* @extends {goog.ui.ToolbarButton}
###
###	
constructor: ->
	super goog.dom.createDom 'div', 'icon tool generate-sql'

startAction: ->
	@dispatchEvent dm.ui.Toolbar.EventType.GENERATE_SQL
###
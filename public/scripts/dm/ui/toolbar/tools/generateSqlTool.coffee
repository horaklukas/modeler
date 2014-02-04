goog.provide 'dm.ui.tools.GenerateSql'

goog.require 'goog.ui.ToolbarButton'

class dm.ui.tools.GenerateSql extends goog.ui.ToolbarButton
	###*
  * @constructor
  * @extends {goog.ui.ToolbarButton}
	###	
	constructor: ->
		super goog.dom.createDom 'div', 'icon tool generate-sql'

	startAction: ->
		alert('GENERATE SQL')
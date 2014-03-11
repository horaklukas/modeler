goog.provide 'dm.ui.tools.GenerateSql'

goog.require 'goog.ui.ToolbarButton'
goog.require 'dm.sqlgen.Sql92'

dm.ui.tools.EventType.GENERATE_SQL = 'generate'

class dm.ui.tools.GenerateSql extends goog.ui.ToolbarButton
	###*
  * @constructor
  * @extends {goog.ui.ToolbarButton}
	###	
	constructor: ->
		super goog.dom.createDom 'div', 'icon tool generate-sql'

	startAction: ->
		@dispatchEvent dm.ui.tools.EventType.GENERATE_SQL
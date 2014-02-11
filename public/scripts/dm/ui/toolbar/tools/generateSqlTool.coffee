goog.provide 'dm.ui.tools.GenerateSql'

goog.require 'goog.ui.ToolbarButton'
goog.require 'dm.sqlgen.Sql92'

class dm.ui.tools.GenerateSql extends goog.ui.ToolbarButton
	###*
  * @constructor
  * @extends {goog.ui.ToolbarButton}
	###	
	constructor: ->
		super goog.dom.createDom 'div', 'icon tool generate-sql'

	startAction: ->
		generator = new dm.sqlgen.Sql92

		generator.generate {
			tables: [
				tab0model
				tab1model
				tab2model
				tab3model
				tab4model
				tab5model
				tab6model
				tab7model
				tab8model
				tab9model
			],
			relations: [
				rel1model
				rel2model
				rel3model
				rel4model
				rel5model
				rel6model
				rel7model
			]
		} 
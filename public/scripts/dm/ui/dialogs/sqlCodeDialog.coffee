`/** @jsx React.DOM */`

goog.provide 'dm.ui.SqlCodeDialog'

goog.require 'dm.ui.Dialog'

dm.ui.SqlCodeDialog = React.createClass
	show: (sql) ->
		@setState visible: true, sqlCode: sql

	getInitialState: ->
		visible: false
		sqlCode: ''

	render: ->
		{visible, sqlCode} = @state
		buttonSet = dm.ui.Dialog.buttonSet.OK

		`(
			<Dialog title="SQL" buttons={buttonSet} visible={visible}>
				<textarea cols="100" rows="20" value={sqlCode} />
			</Dialog>
		)`

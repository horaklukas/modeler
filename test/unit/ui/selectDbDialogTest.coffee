{TestUtils} = React.addons

goog.require 'dm.ui.SelectDbDialog'

describe 'component SelectDbDialog', ->
	props = null
	dlg = null
	dbSelect = null

	before ->
		props =
			dbs: [
				{id: 'db1', title: 'Database 1'}
				{id: 'db2', title: 'Database 2'}
				{id: 'db3', title: 'Database 3'}
			]
		dlg = TestUtils.renderIntoDocument dm.ui.SelectDbDialog props
		dbSelect = TestUtils.findRenderedDOMComponentWithTag dlg, 'select'

	it 'should set first db as a selected in default', ->
		expect(dlg).to.have.deep.property 'state.selectedDb', 'db1'

	it 'should set new selected db when option changed', ->
		TestUtils.Simulate.change dbSelect, target: {value: 'db3'}

		expect(dlg.state).to.have.property 'selectedDb', 'db3'		


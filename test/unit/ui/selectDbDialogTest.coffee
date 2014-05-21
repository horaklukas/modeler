{TestUtils} = React.addons

goog.require 'dm.ui.SelectDbDialog'

describe 'component SelectDbDialog', ->
	props = null
	dlg = null
	dbSelect = null
	cb = sinon.spy()

	before ->
		props =
			dbs:
				'db1': {name: 'Database', version: '1'}
				'db2': {name: 'Database', version: '2'}
				'db3': {name: 'Database', version: '3'}
			onSelect: cb

		dlg = TestUtils.renderIntoDocument dm.ui.SelectDbDialog props
		dbSelect = TestUtils.findRenderedDOMComponentWithTag dlg, 'select'

	beforeEach ->
		cb.reset()

	it 'should supply id of selected db when dialog confirmed', ->
		dlg.handleDbSelect()

		cb.should.been.calledOnce.and.calledWithExactly 'db1'
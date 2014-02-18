mocks = 
	databases: 
		getDbs: sinon.stub(), getList: sinon.stub(), getSelected: sinon.stub()
		setList: sinon.spy()

mockery.enable()
mockery.registerAllowables ['../../../lib/routes', './dbs']
mockery.registerMock './dbs', mocks.databases

routes = require '../../../lib/routes'

describe 'app routes', ->
	req = {}
	res = render: sinon.stub()

	beforeEach ->
		mocks.databases.getList.returns []
		res.render.reset()

	after ->
		mockery.deregisterAll()

	describe.skip 'intro route', ->
		it 'should read definitions directory for all files if list empty', ->
			routes.intro req, res


			mocks.readdir.should.been.calledOnce.and.calledWith 'defs'
			
	describe 'app route', ->

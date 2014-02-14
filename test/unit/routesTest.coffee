mocks = 
	fs: readdir: sinon.stub()
	databases: 
		getDbs: sinon.stub(), getList: sinon.stub(), getSelected: sinon.stub()
		setList: sinon.spy()

mockery.enable()
mockery.registerAllowables ['../../lib/routes', './dbs']
mockery.registerMock 'fs', mocks.fs
mockery.registerMock './dbs', mocks.databases

routes = require '../../lib/routes'

describe 'app routes', ->
	req = {}
	res = render: sinon.stub()

	beforeEach ->
		mocks.databases.getList.returns []
		res.render.reset()
		mocks.fs.readdir.reset()

	after ->
		mockery.deregisterAll()

	describe 'intro route', ->
		it 'should read definitions directory for all files if list empty', ->
			routes.intro req, res

			mocks.fs.readdir.should.been.calledOnce.and.calledWith 'defs'

		it 'should render list without reading directory if list is cached', ->
			mocks.databases.getList.returns ['sql', 'postgre']
			
			routes.intro req, res

			mocks.fs.readdir.should.not.been.called
			res.render.should.been.calledOnce
			res.render.should.been.calledWithExactly 'intro', dbs: ['sql', 'postgre']

		it 'should filter coffee definitions and strip extensions from names', ->
			filesList = [ 'sql.coffee','postgre.coffee','sql.js','postgre.js'	]

			routes.intro req, res
			mocks.fs.readdir.yield null, filesList

			mocks.databases.setList.should.been.calledOnce
			mocks.databases.setList.should.been.calledWithExactly ['sql', 'postgre']
			
	describe 'app route', ->

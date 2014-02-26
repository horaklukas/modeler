mocks = 
	databases: 
		getDb: sinon.stub(), getList: sinon.stub(), getSelected: sinon.stub()
		setList: sinon.spy(), setDbs: sinon.spy(), setSelected: sinon.spy()

mockery.enable()
mockery.registerAllowables ['../../../lib/routes', './dbs']
mockery.registerMock './dbs', mocks.databases

routes = require '../../../lib/routes'

describe 'app routes', ->
	req = {}
	res = 
		render: sinon.spy(), send: sinon.spy()
		redirect: sinon.spy(), expose: sinon.spy()

	after ->
		mockery.deregisterAll()

	describe 'route intro', ->
		beforeEach ->
			mocks.databases.getList.returns []
			mocks.databases.getList.reset()
			res.render.reset()
			res.send.reset()

		it 'should response server error if reading databases failed', ->
			routes.intro req, res
			mocks.databases.getList.yield 'Reading failed'

			res.send.should.been.calledOnce
			res.send.should.been.calledWithExactly 500, {error: 'Reading failed'}

		it 'should pass database list to intro page', ->
			routes.intro req, res
			mocks.databases.getList.yield null, [
				{'postgre': 'PostgreSQL 9.3'}, {'mysql': 'MYSQL 3'}
			]

			res.render.should.been.calledOnce
			res.render.should.been.calledWithExactly 'intro', {dbs: [
				{'postgre': 'PostgreSQL 9.3'}, {'mysql': 'MYSQL 3'}
			]}
			
	describe 'route app', ->
		beforeEach ->
			res.render.reset()
			res.redirect.reset()
			res.expose.reset()
			req.body = {}
			req.method = 'GET'

		it 'should immediatly render workspace if database already selected', ->
			mocks.databases.getSelected.returns 'mysql'
			mocks.databases.getDb.withArgs('mysql').returns types: [], name: 'MYSQL'

			routes.app req, res

			res.redirect.should.not.been.called
			res.expose.should.been.calledOnce
			res.render.should.been.calledOnce
			res.render.should.been.calledWithExactly 'main', {title: 'MYSQL'}

		it 'should redirect to intro if selected db not exists and method POST', ->
			mocks.databases.getSelected.returns null
			req.method = 'POST'
			req.body.dbs = undefined

			routes.app req, res

			res.render.should.not.been.called
			res.expose.should.not.been.called
			res.redirect.should.been.calledOnce.and.calledWithExactly '/'			

		it 'should set selected db and render if req has db to select', ->
			mocks.databases.getSelected.returns null
			mocks.databases.getDb.returns types: [], name: 'PostgreSQL'
			req.method = 'POST'
			req.body.dbs = 'postgres'

			routes.app req, res

			res.redirect.should.not.been.called
			res.expose.should.been.calledOnce
			res.render.should.been.calledOnce
			res.render.should.been.calledWithExactly 'main', {title: 'PostgreSQL'}
			mocks.databases.setSelected.should.been.calledOnce
			mocks.databases.setSelected.should.been.calledWithExactly 'postgres'

		it 'should redirect to intro if db name not and method is GET', ->
			mocks.databases.getSelected.returns null

			routes.app req, res

			res.render.should.not.been.called
			res.expose.should.not.been.called
			res.redirect.should.been.calledOnce.and.calledWithExactly '/'

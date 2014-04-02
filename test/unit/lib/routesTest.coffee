mocks = 
	databases: 
		getDb: sinon.stub(), getList: sinon.stub(), getSelected: sinon.stub()
		setList: sinon.spy(), setDbs: sinon.spy(), setSelected: sinon.spy()


describe 'app routes', ->
	app = null
		
	before ->
		mockery.enable warnOnUnregistered: false
		mockery.registerMock './dbs', mocks.databases

		app = require '../../../app'

	after ->
		mockery.disable()
		mockery.deregisterAll()

	describe 'route list', ->
		beforeEach ->
			#mocks.databases.getList.yields []
			mocks.databases.getList.reset()

		it 'should response server error if reading databases failed', (done) ->
			mocks.databases.getList.yields 'Reading failed'
			
			request(app)
				.post('/list')
				.expect('Content-Type', /text\/html/)
				.expect(500)
				.end (err, res) ->
					if err then return done err

					expect(res.text).to.equal 'Reading failed'
					done()

		it 'should pass database list to intro page', (done) ->
			mocks.databases.getList.yields null, [
				{'postgre': 'PostgreSQL 9.3'}, {'mysql': 'MYSQL 3'}
			]

			request(app)
				.post('/list')
				.expect('Content-Type', /json/)
				.expect(200)
				.end (err, res) ->
					if err then return done err

					expect(res.body).to.have.property 'dbs'
					expect(res.body.dbs).to.be.an('array').and.deep.equal [
						{'postgre': 'PostgreSQL 9.3'}, {'mysql': 'MYSQL 3'}
					]
					done()
			
	describe 'route app', ->
		beforeEach ->
			mocks.databases.getSelected.reset()
			mocks.databases.getDb.reset()

		it 'should render workspace if method is get and selected db exists', (done) ->
			mocks.databases.getSelected.returns 'mysql'
			mocks.databases.getDb.withArgs('mysql').returns types: [], name: 'MYSQL'

			request(app)
				.get('/')
				.expect('Content-Type', /text\/html/)
				.expect(200)
				.expect(/\<title\>MYSQL\<\/title\>/, done)

		it 'should render workspace with exposed list of dbs if method is get and db not selected', (done) ->
			mocks.databases.getSelected.returns 'bla'
			mocks.databases.getDb.withArgs('bla').returns null
			mocks.databases.getList.yields null, [ 
				{id: 'mysql', title: 'MySQL'}, {id: 'sqlite', title: 'SQLite'} 
			]

			request(app)
				.get('/')
				.expect('Content-Type', /text\/html/)
				.expect(200)
				.expect(/\"id\"\:\"mysql\"/)
				.expect(/\"title\"\:\"MySQL\"/)
				.expect(/\"id\"\:\"sqlite\"/)
				.expect(/\"title\"\:\"SQLite\"/, done)

		it 'should response bad request if method is POST and db doesnt exist', (done) ->
			mocks.databases.getSelected.returns null
			
			request(app)
				.post('/')
				.expect('Content-Type', /text/)
				.expect(400)
				.end (err, res) ->
					if err then return done err

					expect(res.text).to.equal 'Id of db doesnt exist'
					done()				

		it 'should set selected db if method is POST and passed db id', (done) ->
			mocks.databases.getSelected.returns null
			
			request(app)
				.post('/')
				.send( {db: 'postgres'} )
				.expect(200)
				.end (err, res) ->
					if err then return done err
			
					mocks.databases.setSelected.should.been.calledOnce
					mocks.databases.setSelected.should.been.calledWithExactly 'postgres'
					done()

		it 'should return db info if method is POST and passed db id', (done) ->
			mocks.databases.getDb.withArgs('postgres').returns {
				types: ['char', 'integer', 'boolean'], name: 'PostgreSQL'
			}

			request(app)
				.post('/')
				.send( {db: 'postgres'} )
				.expect('Content-Type', /json/)
				.expect(200)
				.end (err, res) ->
					if err then return done err

					expect(res.body).to.have.property 'name', 'PostgreSQL'
					expect(res.body).to.have.property('types').that.deep.equal ['char', 'integer', 'boolean']
					done()

	describe 'method saveModel', ->
		it 'should response attachment with name of file if passed', (done) ->
			request(app)
				.post('/save')
				.send({'name': 'model1'})
				.expect('Content-Disposition', 'attachment; filename="model1.json"')
				.expect(200, done)

		it 'should response attachment with `unknown` name of file if not passed', (done)->
			request(app)
				.post('/save')
				.expect('Content-Disposition', 'attachment; filename="unknown.json"')
				.expect(200, done)

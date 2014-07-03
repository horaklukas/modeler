mocks = 
	databases: 
		getDb: sinon.stub(), getList: sinon.stub(), getSelected: sinon.stub()
		setList: sinon.spy(), setDbs: sinon.spy(), setSelected: sinon.spy()
		loadAllDefinitions: sinon.stub()
	export:
		getAppScript: sinon.stub(), getDbDefScript: sinon.stub(), 
		getReactJsScript: sinon.stub(), getAppStyles: sinon.stub()
		compileCss: sinon.stub(), renderTemplate: sinon.stub()
	fs:
		readFile: sinon.stub()
	mkdirp:
		sinon.stub()


describe 'app http routes', ->		
	before ->
		mockery.enable warnOnUnregistered: false
		mockery.registerMock '../dbs', mocks.databases
		mockery.registerMock 'mkdirp', mocks.mkdirp
		mockery.registerMock '../export', mocks.export

		@app = require '../../../app'

	after ->
		mockery.disable()
		mockery.deregisterAll()

	describe.skip 'route list', ->
		beforeEach ->
			#mocks.databases.getList.yields []
			mocks.databases.getList.reset()

		it 'should response server error if reading databases failed', (done) ->
			mocks.databases.getList.yields 'Reading failed'
			
			request(@app)
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

			request(@app)
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

		it.skip 'should render pass info about db if method is get and db selected', (done) ->
			mocks.databases.getSelected.returns 'mysql'
			mocks.databases.getDb.withArgs('mysql').returns types: [], name: 'MYSQL'

			request(@app)
				.get('/')
				.expect('Content-Type', /text\/html/)
				.expect(200)
				.expect(/\<title\>MYSQL\<\/title\>/, done)

		it 'should render workspace with exposed list of dbs if method is get and db not selected', (done) ->
			mocks.databases.getSelected.returns 'bla'
			mocks.databases.getDb.withArgs('bla').returns null
			mocks.databases.loadAllDefinitions.yields null, [ 
				'mysql': { name: 'MySQL'}, 
				'sqlite': { name: 'SQLite'} 
			]

			request(@app)
				.get('/')
				.expect('Content-Type', /text\/html/)
				.expect(200)
				.expect(/\"mysql\"\:\{\"name\"\:\"MySQL\"\}/)
				.expect(/\"sqlite\"\:\{\"name\"\:\"SQLite\"\}/, done)

		it 'should response bad request if method is POST and db doesnt exist', (done) ->
			mocks.databases.getSelected.returns null
			
			request(@app)
				.post('/')
				.expect('Content-Type', /text/)
				.expect(400)
				.end (err, res) ->
					if err then return done err

					expect(res.text).to.equal 'Id of db doesnt exist'
					done()				

		it 'should set selected db if method is POST and passed db id', (done) ->
			mocks.databases.getSelected.returns null
			
			request(@app)
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

			request(@app)
				.post('/')
				.send( {db: 'postgres'} )
				.expect('Content-Type', /json/)
				.expect(200)
				.end (err, res) ->
					if err then return done err

					expect(res.body).to.have.property 'name', 'PostgreSQL'
					expect(res.body).to.have.property('types').that.deep.equal ['char', 'integer', 'boolean']
					done()

	describe 'route saveModel', ->
		it 'should response attachment with name of file if passed', (done) ->
			request(@app)
				.post('/save')
				.send({'name': 'model1'})
				.expect('Content-Disposition', 'attachment; filename="model1.json"')
				.expect(200, done)

		it 'should response attachment with `unknown` name of file if not passed', (done)->
			request(@app)
				.post('/save')
				.expect('Content-Disposition', 'attachment; filename="unknown.json"')
				.expect(200, done)

	describe 'route exportModel', ->
		beforeEach ->
			mocks.export.getAppScript.yields null, 'app-script'
			mocks.export.getDbDefScript.yields null, 'script'
			mocks.export.getReactJsScript.yields null, 'react-js-script'
			mocks.export.getAppStyles.yields null, 'app-css'
			mocks.export.compileCss.withArgs('app-css').returns 'compiled-css' 

		it 'should response attachment with rendered template', (done) ->
			mocks.export.getDbDefScript
				.withArgs('sql-1', 'passed db model').yields null, 'db-def-script'
			mocks.export.renderTemplate
				.withArgs('react-js-script\ndb-def-script\napp-script', 'compiled-css')
				.yields null, 'rendered template content' 

			request(@app)
				.post('/export')
				.send({dbid: 'sql-1', model: 'passed db model'})
				.expect('Content-Disposition', 'attachment; filename="exported.html"')
				.expect(200)
				.expect(/rendered template content/ , done)

		it 'should response with error if getting any source failed', (done) ->
			mocks.export.getDbDefScript.withArgs('sql', 'mdl').yields null, 'script'
			mocks.export.getAppScript.yields 'build err'

			request(@app)
				.post('/export')
				.send({dbid: 'sql', model: 'mdl'})
				.expect('Content-Type', /text/)
				.expect(500)
				.end (err, res) ->
					if err then return done err

					expect(res.text).to.equal 'Error at getting source code: build err'
					done()

		it 'should reponse with error if rendering failed', (done) ->
			mocks.export.getDbDefScript
				.withArgs('sql', 'mdl').yields null, 'db-def-script'
			mocks.export.renderTemplate
				.withArgs('react-js-script\ndb-def-script\napp-script', 'compiled-css')
				.yields 'render error'

			request(@app)
				.post('/export')
				.send({dbid: 'sql', model: 'mdl'})
				.expect('Content-Type', /text/)
				.expect(500)
				.end (err, res) ->
					if err then return done err

					expect(res.text).to.equal 'Error at rendering template: render error'
					done()

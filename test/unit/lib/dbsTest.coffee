mocks = 
	fs: readdir: sinon.stub()

mockery.enable()
mockery.registerMock 'fs', mocks.fs

databases = require '../../../lib/dbs'

describe 'Module dbs', ->
	cb = sinon.spy()

	describe 'method getList', ->
		before ->
			sinon.stub databases, 'loadAllDefinitions'

		beforeEach ->
			cb.reset()
			databases.loadAllDefinitions.reset()
			databases.setDbs null # clear list of databases

		after ->
			databases.loadAllDefinitions.restore()
			mockery.deregisterAll()
			mockery.disable()

		it 'should pass error to calback if loading definitions failed', ->
			databases.getList cb
			databases.loadAllDefinitions.yield 'Error at loading definitions'

			cb.should.been.calledWithExactly 'Error at loading definitions'

		it 'should pass response with list of databases after its load', ->
			databases.getList cb
			databases.setDbs {
				'postgre9':{name:'POSTGRES',version:'9'}
				'sqlite1':{name:'SQLITE',version:'1'}
			}
			databases.loadAllDefinitions.yield()

			cb.should.been.calledWithExactly null, [
				{ id: 'postgre9', title: 'POSTGRES 9'}
				{ id: 'sqlite1', title: 'SQLITE 1'}
			]			

		it 'should response with list of databases if loaded already', ->
			databases.setDbs {
				'mysql8':{name:'MYSQL',version:'8'},'sql92':{name:'SQL',version:'92'}
			}

			databases.getList cb

			databases.loadAllDefinitions.should.not.been.called
			cb.should.been.calledWithExactly null, [
				{ id: 'mysql8', title: 'MYSQL 8'}
				{ id: 'sql92', title: 'SQL 92'}
			]

	describe 'method loadAllDefinitions', ->
		before ->
			sinon.stub databases, 'loadDefinition'

		beforeEach ->
			cb.reset()
			mocks.fs.readdir.reset()
			databases.loadDefinition.reset()
			databases.setDbs null # clear list of databases

		after ->
			databases.loadDefinition.restore()

		it 'should pass error to callback if reading defs dir failed', ->
			databases.loadAllDefinitions cb
			mocks.fs.readdir.yield 'Error at reading dir'

			cb.should.been.calledWithExactly 'Error at reading defs dir!'

		it 'should load definition for each definition file', ->
			filesList = [ 'sql.coffee','postgre.coffee','sql.js','postgre.js'	]

			databases.loadAllDefinitions cb
			mocks.fs.readdir.yield null, filesList

			cb.should.been.calledOnce

			databases.loadDefinition.should.been.calledTwice
			databases.loadDefinition.should.been.calledWith 'sql'
			databases.loadDefinition.should.been.calledWith 'postgre'

		it 'should pass error to callback if loading any definition failed', ->
			databases.loadDefinition.withArgs('postgre').throws message: 'Error of sql def'

			databases.loadAllDefinitions cb
			mocks.fs.readdir.yield null, ['mysql.js', 'postgre.js', 'sqlite.js']

			databases.loadDefinition.should.been.calledTwice
			cb.should.been.calledOnce.and.calledWithExactly 'Error of sql def'
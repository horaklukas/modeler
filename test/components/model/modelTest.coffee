Model = require "#{scriptsDir}/components/model/model"
model = null
canvas = $('canvas')

describe 'class Model', ->
	before ->
		model = new Model('model1')

	describe 'constructor', ->
		it 'should throw error if name of model not defined', ->
			expect(-> new Model()).to.throw 'Model name must be specified!'

		it 'should create empty lists of tables and relations', ->
			model.tables.should.be.an('array').and.be.empty
			model.relations.should.be.an('array').and.be.empty

	describe 'method addTable', ->
		global.Table = sinon.stub().returns  {x: 40; y: 30}

		before ->
			model.addTable '<canvas>', 38, 64

		it 'should take passed canvas and positon make id and create table', ->
			Table.should.been.calledWith '<canvas>', 'tab_0', 38, 64

		it 'should save created table to list', ->
			model.addTable '<canvas2>', 20, 160

			model.tables.should.have.length 2
			model.tables[0].should.deep.equal {x:40, y: 30}
			model.tables[1].should.deep.equal {x:40, y: 30}

	describe 'method addRelation', ->
		global.Relation = sinon.stub().returns {id: 'rel'}
		gtni = null
		before ->
			gtni = sinon.stub model, 'getTabNumberId'
			gtni.withArgs(1).returns 0
			gtni.withArgs(2).returns 1
			gtni.withArgs(3).returns 2
			gtni.withArgs(4).returns 3
			model.tables = [{addRelation: sinon.spy()}, {addRelation: sinon.spy()}]

		after ->
			gtni.restore()
			model.tables = []

		it 'should return false if start or end table isnt found', ->
			expect(model.addRelation '<canvas>', 3, 4).to.be.false
			expect(model.addRelation '<canvas>', 1, 3).to.be.false
			expect(model.addRelation '<canvas>', 2, 4).to.be.false

		it 'should add new relation to the list of relations', ->
			model.addRelation '<c>', 1, 2

			expect(Relation).to.be.calledWith '<c>', model.tables[0], model.tables[1]
			expect(model.relations).to.have.length 1
			expect(model.relations[0]).to.deep.equal {id: 'rel'}

		it 'should add relation reference to end tables', ->
			model.addRelation '<c>', 1, 2

			expect(model.tables[0].addRelation).to.been.calledWith {id: 'rel'}
			expect(model.tables[1].addRelation).to.been.calledWith {id: 'rel'}

	describe 'method getTabNumberId', ->
		it 'should return the id number if id has right format', ->
			expect(model.getTabNumberId('tab_0'), 'tab_0').to.be.a('number')
			.and.equal 0
			expect(model.getTabNumberId('tab_23'), 'tab_23').to.be.a('number')
			.and.equal 23
			expect(model.getTabNumberId('tab_123'), 'tab_123').to.be.a('number')
			.and.equal 123

		it 'should return false id if has wrong format', ->
			expect(model.getTabNumberId('tab_12f'), 'tab_12f').to.be.false
			expect(model.getTabNumberId('tabb_13'), 'tab_13').to.be.false
			expect(model.getTabNumberId('tab_ds2'), 'tab_ds2').to.be.false
			expect(model.getTabNumberId('tab_'), 'tab_').to.be.false


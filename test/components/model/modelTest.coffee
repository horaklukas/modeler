Model = require "#{srcDir}/components/model/model"
model = null
canvas = $('canvas')

describe 'class Model', ->
	model = new Model('model1')

	describe 'constructor', ->
		it 'should throw error if name of model not defined', ->
			expect(-> new Model()).to.throw 'Model name must be specified!'

		it 'should create empty lists of tables and relations', ->
			model.tables.should.be.an('array').and.empty
			model.relations.should.be.an('array').and.empty

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


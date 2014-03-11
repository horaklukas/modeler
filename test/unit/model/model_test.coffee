goog.require 'dm.model.Model'

describe 'class model.Model', ->
	model = null

	before ->
		model = new dm.model.Model('model1')

	describe 'constructor', ->
		it 'should throw error if name of model not defined', ->
			expect(-> new dm.model.Model()).to.throw 'Model name must be specified!'

		it 'should create empty lists of tables and relations', ->
			model.should.have.property('tables_').that.is.an('object').and.empty
			model.should.have.property('relations_').that.is.an('object').and.empty

	describe 'method addTable', ->
		beforeEach ->
			model.tables_ = {}

		it 'add save table model by table id', ->
			table = 
				getId: sinon.stub().returns 'id1'
				getModel: sinon.stub().returns 'model1'

			model.addTable table 

			expect(model).to.have.deep.property 'tables_.id1', 'model1'

	describe 'method addRelation', ->
		beforeEach ->
			model.relations_ = {}

		it 'should save relation model by relation id', ->
			relation =
				getId: sinon.stub().returns 'rel1'
				getModel: sinon.stub().returns 'model2'

			model.addRelation relation

			expect(model).to.have.deep.property 'relations_.rel1', 'model2'

	describe 'method getTablesByName', ->
		tab1 = getName: (-> 'table1'), id: 'tb1'
		tab2 = getName: (-> 'table2'), id: 'tb2'
		tab3 = getName: (-> 'table3'), id: 'tb3'

		beforeEach ->
			model.tables_ = { 'tab1': tab1, 'tab2': tab2, 'tab3': tab3	}

		it 'should return tables with their names as a keys', ->
			tabsByName = model.getTablesByName()

			expect(tabsByName).to.be.an('object')
			expect(tabsByName).to.have.deep.property 'table1', tab1
			expect(tabsByName).to.have.deep.property 'table2', tab2
			expect(tabsByName).to.have.deep.property 'table3', tab3
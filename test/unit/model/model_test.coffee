goog.require 'dm.model.Model'

describe 'class model.Model', ->
	model = null

	before ->
		model = new dm.model.Model('model1')

	describe 'constructor', ->
		it 'should throw error if name of model not defined', ->
			expect(-> new dm.model.Model()).to.throw 'Model name must be specified!'

		it 'should save `name` as a public attribute', ->
			expect(model).to.have.property 'name', 'model1'

		it 'should create empty lists of tables and relations', ->
			model.should.have.property('tables_').that.is.an('object').and.empty
			model.should.have.property('relations_').that.is.an('object').and.empty

		it 'should create empty map of related relations and tables', ->
			model.should.have.property('relationsByTable').that.is.empty

	describe 'method addTable', ->
		beforeEach ->
			model.tables_ = {}

		it 'add save table by table id', ->
			table = 
				getId: sinon.stub().returns 'id1'
				getModel: sinon.stub().returns 'model1'

			model.addTable table 

			expect(model).to.have.deep.property 'tables_.id1'
			expect(model.tables_.id1).to.deep.equal table

	describe 'method getTableById', ->
		before ->
			model.tables_ =
				'tab1': getModel: -> 'model1'
				'tab2': getModel: -> 'model2'
				'tab3': getModel: -> 'model3'

		it 'should return model of passed table', ->
			expect(model.getTableById 'tab3').to.equal 'model3'
			expect(model.getTableById 'tab1').to.equal 'model1'			

		it 'should return null if table with passed id doesnt exist', ->
			expect(model.getTableById 'tab4').to.be.null

	describe 'method getRelationById', ->
		before ->
			model.relations_ =
				'rel1': getModel: -> 'model1'
				'rel2': getModel: -> 'model2'
				'rel3': getModel: -> 'model3'

		it 'should return model of passed relation', ->
			expect(model.getRelationById 'rel3').to.equal 'model3'
			expect(model.getRelationById 'rel1').to.equal 'model1'			

		it 'should return null if table with passed id doesnt exist', ->
			expect(model.getRelationById 'tab4').to.be.null

	describe 'method addRelation', ->
		relation = null
		relmodel = null

		beforeEach ->
			model.relations_ = {}
			model.relationsByTable = {}

			relmodel =
				tables:
					parent: getId: sinon.stub().returns 'p1'
					child: getId: sinon.stub().returns 'ch1'

			relation =
				getId: sinon.stub().returns 'rel3'
				getModel: sinon.stub().returns relmodel

		it 'should save relation by relation id', ->
			model.addRelation relation

			expect(model).to.have.deep.property 'relations_.rel3'
			expect(model.relations_.rel3).to.deep.equal relation

		it 'should assign id of relation to related tables lists', ->
			model.relationsByTable = 
				'tab1': ['rel1', 'rel2']
				'tab2': ['rel5']
				'tab3': ['rel4']

			relmodel.tables.parent.getId.returns 'tab1'
			relmodel.tables.child.getId.returns 'tab3'

			model.addRelation relation

			expect(model.relationsByTable.tab1).to.contain 'rel3' 
			expect(model.relationsByTable.tab3).to.contain 'rel3' 

		it 'should create new list of relation if not exist for related tables', ->
			model.relationsByTable = 
				't1': ['rel1', 'rel2']
				't3': ['rel4']

			relmodel.tables.parent.getId.returns 't2'
			relmodel.tables.child.getId.returns 't5'

			model.addRelation relation

			expect(model.relationsByTable).to.have.property 't2'
			expect(model.relationsByTable.t2).to.deep.equal ['rel3'] 
			expect(model.relationsByTable).to.have.property 't5'
			expect(model.relationsByTable.t5).to.deep.equal ['rel3'] 
 
	describe 'method getTables', ->
		before ->
			model.tables_ =
				'tab1': getModel: -> 'tmdl1'
				'tab2': getModel: -> 'tmdl2'
				'tab3': getModel: -> 'tmdl3'

		it 'should return list of tables models', ->
			expect(model.getTables()).to.deep.equal ['tmdl1', 'tmdl2', 'tmdl3']

	describe 'method getRelations', ->
		before ->
			model.relations_ =
				'rel1': getModel: -> 'rmdl1'
				'rel2': getModel: -> 'rmdl2'
				'rel3': getModel: -> 'rmdl3'

		it 'should return list of realations models', ->
			expect(model.getRelations()).to.deep.equal ['rmdl1', 'rmdl2', 'rmdl3']

	describe 'method getTablesByName', ->
		model1 = getName: (-> 'table1'), id: 'tb1'
		model2 = getName: (-> 'table2'), id: 'tb2'
		model3 = getName: (-> 'table3'), id: 'tb3'
		tab1 = null
		tab2 = null
		tab3 = null

		before ->
			tab1 = getModel: -> model1
			tab2 = getModel: -> model2
			tab3 = getModel: -> model3

		beforeEach ->
			model.tables_ = { 'tab1': tab1, 'tab2': tab2, 'tab3': tab3	}

		it 'should return tables with their names as a keys', ->
			tabsByName = model.getTablesByName()

			expect(tabsByName).to.be.an('object')
			expect(tabsByName).to.have.deep.property 'table1', model1
			expect(tabsByName).to.have.deep.property 'table2', model2
			expect(tabsByName).to.have.deep.property 'table3', model3

	describe 'getTableIdByName', ->
		tab1 = null
		tab2 = null
		tab3 = null

		before ->
			tab1 = getModel: (-> {getName: (-> 'table1')}), getId: -> 'tb1'
			tab2 = getModel: (-> {getName: (-> 'table2')}), getId: -> 'tb2'
			tab3 = getModel: (-> {getName: (-> 'table3')}), getId: -> 'tb3'

		beforeEach ->
			model.tables_ = { 'tab1': tab1, 'tab2': tab2, 'tab3': tab3	}

		it 'should return id of table by table name', ->
			expect(model.getTableIdByName 'table2').to.equal 'tb2'
			expect(model.getTableIdByName 'table1').to.equal 'tb1'
			expect(model.getTableIdByName 'table3').to.equal 'tb3'

	describe 'method toJSON', ->
		before ->
			model.name = 'model1'
			model.tables_ = 
				'tab1': 
					getModel: -> toJSON: -> {name: 't1', columns: ['c1', 'c2']}
					getPosition: -> new goog.math.Coordinate 45, 180 
				'tab2': 
					getModel: -> toJSON: -> {name: 't2', columns: ['c3', 'c5']}
					getPosition: -> new goog.math.Coordinate 354, 20 
				'tab3': 
					getModel: -> toJSON: -> {name: 't3', columns: ['c4', 'c7']}
					getPosition: -> new goog.math.Coordinate 480, 335 
			model.relations_ =
				'rel1': getModel: -> toJSON: -> {par: 't1', chld: 't2', ident: true}
				'rel2': getModel: -> toJSON: -> {par: 't2', chld: 't3', ident: false}

		it 'should return JSON representation of complete model data', ->
			json = model.toJSON()

			expect(json).to.deep.equal {
				'name': 'model1'
				'tables': [
					{	
						'model': {name: 't1', columns: ['c1', 'c2']}
						'pos': {'x': 45, 'y': 180}
					}
					{	
						'model': {name: 't2', columns: ['c3', 'c5']}
						'pos': {'x': 354, 'y': 20}
					}
					{
						'model': {name: 't3', columns: ['c4', 'c7']}
						'pos': {'x': 480, 'y': 335}
					}
				]
				'relations': [
					{ par: 't1', chld: 't2', ident: true }
					{ par: 't2', chld: 't3', ident: false }
				]
			}
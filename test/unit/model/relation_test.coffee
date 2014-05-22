goog.require 'dm.model.Relation'

describe 'class model.Relation', ->
	rel = null

	before ->
		rel = new dm.model.Relation true

	describe 'constructor', ->
		it 'should save type of relation', ->
			expect(rel).to.have.property 'identifying_', true

		it 'should init empty columns mapping', ->
			expect(rel).to.have.property('keyColumnsMapping_').that.is.empty

	describe 'method setType', ->
		it 'should set new type of relation', ->
			rel.setType false

			expect(rel).to.have.property 'identifying_', false

		it 'should dispatch `type-change` event', ->
			spy = sinon.spy()
			rel.listen 'type-change', spy

			rel.setType true

			spy.should.been.calledOnce

	describe.skip 'method setRelatedTables', ->
		beforeEach ->
			rel.tables = parent: '', child: ''

		it 'should set new parent table name if passed', ->
			rel.setRelatedTables 'parentTable'

			expect(rel).to.have.deep.property 'tables.parent', 'parentTable'
			expect(rel).to.have.deep.property 'tables.child', ''

		it 'should set new child table name if passed', ->
			rel.setRelatedTables null, 'childTable'

			expect(rel).to.have.deep.property 'tables.child', 'childTable'
			expect(rel).to.have.deep.property 'tables.parent', ''

	describe 'method toJSON', ->
		beforeEach ->
			rel.setType true
			rel.setColumnsMapping [
				{ 'parent': 1, 'child': 2 }
				{ 'parent': 2, 'child': 4 }
				{ 'parent': 3, 'child': 5 }
			]
			rel.tables.parent = getModel: -> getName: -> 'parent1'
			rel.tables.child = getModel: -> getName: -> 'child2'

		it 'should return JSON like representation of model', ->
			json = rel.toJSON 'parent1', 'child2'

			expect(json).to.have.property 'type', true
			expect(json).to.have.deep.property 'mapping[0].parent', 1
			expect(json).to.have.deep.property 'mapping[0].child', 2
			expect(json).to.have.deep.property 'mapping[1].parent', 2
			expect(json).to.have.deep.property 'mapping[1].child', 4
			expect(json).to.have.deep.property 'mapping[2].parent', 3
			expect(json).to.have.deep.property 'mapping[2].child', 5
			expect(json).to.have.deep.property 'tables.parent', 'parent1'
			expect(json).to.have.deep.property 'tables.child', 'child2'

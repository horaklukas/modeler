goog.require 'dm.ui.Relation'
goog.require 'goog.events.EventTarget'
goog.require 'goog.graphics.CanvasGraphics'

describe 'class Relation', ->
	rel = null
	gr = null
	fakeModel = null 
	
	before ->
		gr = new goog.graphics.CanvasGraphics
		fakeModel = new goog.events.EventTarget()
		fakeModel.getName = sinon.stub()
		fakeModel.getColumns = sinon.stub()

		rel = new dm.ui.Relation gr

	describe 'constructor', ->

	describe 'getPathDistance', ->
		it 'should return distance if position type are equal', ->
			d = rel.getPathDistance 'right', {x: 10, y: 30}, 'right', {x: 45, y: 61}
		
			expect(d).should.be.a.number

		it 'should count distance between two points as sum of two distances', ->
			d = rel.getPathDistance 'top', {x: 23, y: 34}, 'top', {x: 45, y: 67}	

			expect(d).to.equal 55

		it 'should count positive distance if second point is before first', ->
			d = rel.getPathDistance 'top', {x: 54, y: 123}, 'top', {x: 45, y: 67}	

			expect(d).to.equal 65

	describe 'getTableConnectionPoints', ->
		gb = null

		before ->
			gb = sinon.stub goog.style, 'getBounds'

		beforeEach ->
			gb.reset()

		after ->
			gb.restore()

		it 'should count top position from table bounds', ->
			gb.returns left:38, top:45, width: 124

			coord = rel.getTableConnectionPoints getElement: -> 'table'
			coord.should.have.deep.property 'top.x', 98
			coord.should.have.deep.property 'top.y', 14

		it 'should count right position from table bounds', ->
			gb.returns left:74, top:63, width:56 , height: 88

			coord = rel.getTableConnectionPoints getElement: -> 'table'
			coord.should.have.deep.property 'right.x', 128
			coord.should.have.deep.property 'right.y', 76

		it 'should count bottom position from table bounds', ->
			gb.returns left:81, top:15, width: 130, height: 90

			coord = rel.getTableConnectionPoints getElement: -> 'table'
			coord.should.have.deep.property 'bottom.x', 144
			coord.should.have.deep.property 'bottom.y', 74

		it 'should count left position from table bounds', ->
			gb.returns left:14, top:13, height: 90

			coord = rel.getTableConnectionPoints getElement: -> 'table'
			coord.should.have.deep.property 'left.x', 12
			coord.should.have.deep.property 'left.y', 27

	describe.skip 'getRelationPath', ->
		grp = null
		fakepath = moveTo: sinon.spy(), lineTo: sinon.spy()

		before ->
			grp = sinon.stub rel, 'getRelationPoints'

		beforeEach ->
			fakepath.moveTo.reset()
			fakepath.lineTo.reset()

		after ->
			grp.restore()

		it 'should move to right points when relation is vertical', ->
			grp.returns
				start: edge: 'top', coords: { x: 23, y: 23 }
				stop: edge: 'bottom', coords: { x: 20, y: 54 } 
		
			rel.getRelationPath fakepath

			fakepath.moveTo.should.been.calledWithExactly 21, 23
			fakepath.lineTo.should.been.calledWithExactly 18, 54
			fakepath.lineTo.should.been.calledWithExactly 22, 54
			fakepath.lineTo.should.been.calledWithExactly 25, 23

		it 'should move to right points when relation is horizontal', ->
			grp.returns
				start: edge: 'left', coords: { x: 23, y: 51 }
				stop: edge: 'right', coords: { x: 68, y: 54 } 

			rel.getRelationPath fakepath

			fakepath.moveTo.should.been.calledWithExactly 23, 49
			fakepath.lineTo.should.been.calledWithExactly 68, 52
			fakepath.lineTo.should.been.calledWithExactly 68, 56
			fakepath.lineTo.should.been.calledWithExactly 23, 53

		it 'should move to right points when relation is increasing to right', ->
			grp.returns
				start: edge: 'right', coords: { x: 23 , y: 90 }
				stop: edge: 'bottom', coords: { x: 79, y:  22} 

			rel.getRelationPath fakepath

			fakepath.moveTo.should.been.calledWithExactly 23, 88
			fakepath.lineTo.should.been.calledWithExactly 77, 22
			fakepath.lineTo.should.been.calledWithExactly 81, 22
			fakepath.lineTo.should.been.calledWithExactly 23, 92

		it 'should move to right points when relation is increasing to left', ->
			grp.returns
				start: edge: 'left', coords: { x: 65, y: 97 }
				stop: edge: 'bottom', coords: { x: 31, y: 35 } 

			rel.getRelationPath fakepath

			fakepath.moveTo.should.been.calledWithExactly 65, 95
			fakepath.lineTo.should.been.calledWithExactly 33, 35
			fakepath.lineTo.should.been.calledWithExactly 29, 35
			fakepath.lineTo.should.been.calledWithExactly 65, 99

		it 'should move to right points when relation is decreasing to right', ->
			grp.returns
				start: edge: 'right', coords: { x: 13 , y: 56 }
				stop: edge: 'top', coords: { x: 67, y:  104} 

			rel.getRelationPath fakepath

			fakepath.moveTo.should.been.calledWithExactly 13, 54
			fakepath.lineTo.should.been.calledWithExactly 65, 104
			fakepath.lineTo.should.been.calledWithExactly 69, 104
			fakepath.lineTo.should.been.calledWithExactly 13, 58

		it 'should move to right points when relation is decreasing to left', ->
			grp.returns
				start: edge: 'left', coords: { x: 89, y: 42 }
				stop: edge: 'top', coords: { x: 19, y: 98 } 

			rel.getRelationPath fakepath

			fakepath.moveTo.should.been.calledWithExactly 89, 40
			fakepath.lineTo.should.been.calledWithExactly 17, 98
			fakepath.lineTo.should.been.calledWithExactly 21, 98
			fakepath.lineTo.should.been.calledWithExactly 89, 44

	describe.skip 'method setRelatedTables', ->
		srtk = null
		model = null
		gfci = sinon.stub()

		before ->
			srtk = sinon.stub rel, 'setRelatedTablesKeys'
			model =	removeColumn: sinon.spy()
			sinon.stub(rel, 'getModel').returns {
				getFkColumnsIds: gfci, setRelatedTables: sinon.spy()
			}
			sinon.stub rel, 'setTablesNamesToModel'
			sinon.stub goog.events, 'listen'

		beforeEach ->
			rel.childTab = null
			rel.parentTab = null
			gfci.reset()
			model.removeColumn.reset()
			goog.events.listen.reset()

		after ->
			srtk.restore()
			rel.getModel.restore()
			rel.setTablesNamesToModel.restore()
			goog.events.listen.restore()

		it 'should delete fk columns of previous child table if exists', ->
			rel.childTab = getModel: -> model
			gfci.returns [4, 5]

			rel.setRelatedTables {getModel: -> 'parent'}, {getModel: -> 'child'}

			model.removeColumn.should.been.calledTwice
			model.removeColumn.should.been.calledWithExactly 4
			model.removeColumn.should.been.calledWithExactly 5

		it 'should delete fk columns in descending order', ->
			rel.childTab = getModel: -> model
			rm6 = model.removeColumn.withArgs(6)
			rm5 = model.removeColumn.withArgs(5)
			rm4 = model.removeColumn.withArgs(4)
			gfci.returns [4, 5, 6]

			rel.setRelatedTables {getModel: -> 'parent'}, {getModel: -> 'child'}

			model.removeColumn.should.been.calledThrice
			rm6.should.been.calledBefore rm5
			rm5.should.been.calledBefore rm4

		it 'should listen for recount position if tables columns change', ->
			events = ['column-add', 'column-delete']

			rel.setRelatedTables(
				{getModel: -> 'parentModel'}, {getModel: -> 'childModel'}
			)

			goog.events.listen.should.been.calledWithExactly(
				'parentModel', events, rel.recountPosition
			)
			goog.events.listen.should.been.calledWithExactly(
				'childModel', events, rel.recountPosition
			)

	describe 'method setRelatedTableKeys', ->
		gcols = sinon.stub()
		gcolid = sinon.stub()
		scol = sinon.stub()
		sindex = sinon.spy()
		iident = sinon.stub()
		scm = sinon.spy()
		parentModel = null
		childModel = null

		before ->
			parentModel = getColumns: gcols, getColumnsIdsByIndex: gcolid
			childModel = setColumn: scol, setIndex: sindex	

			sinon.stub(rel, 'getModel').returns {
				isIdentifying: iident, setColumnsMapping: scm
			}

		beforeEach ->
			gcols.reset()
			gcolid.reset()
			scol.reset()
			iident.reset()
			sindex.reset()
			scm.reset()

		after ->
			rel.getModel.restore()

		it 'should add primary column from parent table to child table', ->
			iident.returns true
			gcols.returns [	{name:'notPk1'},{name:'Pk1'},{name:'notPk2'} ]
			gcolid.returns [1]
			scol.withArgs({name:'Pk1'}).returns 1

			rel.setRelatedTablesKeys parentModel, childModel

			scol.should.been.calledOnce.and.calledWithExactly name: 'Pk1'
			sindex.should.been.calledTwice
			sindex.should.been.calledWithExactly 1, dm.model.Table.index.PK
			sindex.should.been.calledWithExactly 1, dm.model.Table.index.FK

		it 'should add primary column from parent to child as a non primary', ->
			iident.returns false
			gcols.returns [	{name:'notPk1'},{name:'notPk2'},{name:'Pk11'} ]
			gcolid.returns [2]
			scol.withArgs({name:'Pk11'}).returns 2

			rel.setRelatedTablesKeys parentModel, childModel

			scol.should.been.calledOnce.and.calledWithExactly name: 'Pk11'
			sindex.should.been.calledOnce
			sindex.should.been.calledWithExactly 2, dm.model.Table.index.FK

		it 'should left original column be primary even if child column change', ->
			parentColumns = [	{name:'notPk1'},{name:'Pk2'},{name:'notPk2'}	]
			gcolid.returns [1]

			iident.returns false
			gcols.returns parentColumns

			rel.setRelatedTablesKeys parentModel, childModel

			scol.should.been.calledOnce.and.calledWithExactly name: 'Pk2'
			parentColumns[1].should.deep.equal name: 'Pk2'

		it 'should save mapping of fk-> pk columns id', ->
			parentColumns = [	{name:'nPk1'},{name:'nPk2'},{name:'Pk2'},{name:'Pk3'}	]
			gcolid.returns [2, 3]
			scol.withArgs({name:'Pk2'}).returns 4
			scol.withArgs({name:'Pk3'}).returns 5
			gcols.returns parentColumns

			rel.setRelatedTablesKeys parentModel, childModel

			scm.should.been.calledOnce.and.calledWithExactly [
				{ parent: 2, child: 4 }, { parent: 3, child: 5 }
			]
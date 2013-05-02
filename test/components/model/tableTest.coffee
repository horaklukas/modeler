Table = require "#{scriptsDir}/components/model/table"
tab = null
canvas = $('canvas')

describe 'class Table', ->
	describe 'constructor', ->
		before ->
			tab = new Table canvas, 'tab25' , 70, 50

		it 'should set `id` attribute to table', ->
			expect(tab.table.attr 'id').to.equal 'tab25'

		it 'should have position properties', ->
			tab.should.have.deep.property 'position.current.x'
			tab.should.have.deep.property 'position.current.y'
			tab.should.have.deep.property 'position.startmove.relative.x'
			tab.should.have.deep.property 'position.startmove.relative.y'
			tab.should.have.deep.property 'position.startmove.absolute.x'
			tab.should.have.deep.property 'position.startmove.absolute.y'

		it 'should set passed position as startmove and current position', ->
			expect(tab.position.current.x).to.equal 70
			expect(tab.position.current.y).to.equal 50
			expect(tab.position.startmove.relative.y).to.equal 50
			expect(tab.position.startmove.relative.y).to.equal 50
			expect(tab.position.startmove.absolute.x).to.equal null
			expect(tab.position.startmove.absolute.y).to.equal null

		it 'should create table object with header', ->
			expect(tab.table.hasClass('table')).to.be.true
			expect(tab.table.children('span.head')).to.have.length 1

		it 'should have passed x and y as proerties left and top', ->
			expect(tab.table.css('left')).to.equal '70px'
			expect(tab.table.css('top')).to.equal '50px'

		it 'should set default size if no passed', ->
			expect(tab.table.width()).to.equal 100
			expect(tab.table.height()).to.equal 80

		it 'should set the size if passed', ->
			tab2 = new Table canvas, 'id', 0, 0, 40, 120
			expect(tab2.table.width()).to.equal 40
			expect(tab2.table.height()).to.equal 120
	
	describe 'startTable', ->
		fakeEv = pageX: 110, pageY: 230
		mPos = null

		before ->
			tab = new Table canvas, 'id', 0, 0
			mPos = sinon.stub(tab.table, 'position').returns left: 60, top: 100

		after ->
			mPos.reset()

		it 'should set position, relative and current coordinates', ->
			tab.startTable fakeEv

			tab.position.current.should.deep.equal x: 60, y: 100
			tab.position.startmove.relative.should.deep.equal x: 60, y: 100
			tab.position.startmove.absolute.should.deep.equal x: 110, y: 230

	describe 'moveTable', ->
		fakeEv = pageX: 100, pageY: 150, data: {maxX: 300, maxY: 500}
		startEv = pageX: 100, pageY: 150
		mPos = null
		mCss = null

		before ->
			tab = new Table canvas, 'id', 20, 20, 70, 50
			mPos = sinon.stub(tab.table, 'position').returns left: 20, top: 30
			mCss = sinon.stub(tab.table, 'css')

		after ->
			mPos.reset()
			mCss.reset()	

		it 'should add class `move` to table', ->
			tab.moveTable pageX: 0, pageY: 0, data: {maxX: 30, maxY: 50}
			expect(tab.table.hasClass('move')).to.be.true

		it 'should count correct coordinates when imputing coordintes', ->
			tab.startTable startEv
			fakeEv.pageX = 130
			fakeEv.pageY = 175
			tab.moveTable fakeEv

			# 20 + (130 -100) and 30 + (175 - 150)
			mCss.should.been.calledWithExactly left: 50, top: 55
			tab.position.current.should.deep.equal x: 50, y: 55

		it 'should count correct coordinates when subtracting coordintes', ->
			tab.startTable startEv
			fakeEv.pageX = 90
			fakeEv.pageY = 125
			tab.moveTable fakeEv

			# 20 + (90 -100) and 30 + (125 - 150)
			mCss.should.been.calledWithExactly left: 10, top: 5
			tab.position.current.should.deep.equal x: 10, y: 5

		it 'should set coords to canvas max minus table size if table is outside canvas', ->
			tab.startTable startEv
			fakeEv.pageX = 460
			fakeEv.pageY = 690
			tab.moveTable fakeEv

			# 20 + (460 -100 - 70) = 310  and 30 + (690 - 150 - 50) = 520
			# x max is 300 - 70 = 230 and y max is 500 - 50 = 450
			mCss.should.been.calledWithExactly left: 230, top: 450	
			tab.position.current.should.deep.equal x: 230, y: 450 	

		it 'should set coords to canvas min if coords are lower than min', ->
			tab.startTable startEv
			fakeEv.pageX = 30
			fakeEv.pageY = 100
			tab.moveTable fakeEv

			# 20 + (30 -100) = -50  and 30 + (100 - 150) = -20
			mCss.should.been.calledWithExactly left: 0, top: 0
			tab.position.current.should.deep.equal x: 0, y: 0

		it 'should recount position of each related relation', ->
			cb = sinon.spy()
			tab.relations = [{recountPosition: cb}, {recountPosition: cb}]
			tab.moveTable fakeEv

			cb.should.been.calledTwice	

	describe 'stopTable', ->
		before ->
			tab = new Table canvas, 'id', 0, 0

		it 'should remove class `move` from table', ->
			tab.moveTable pageX: 0, pageY: 0, data: {maxX: 30, maxY: 50}
			expect(tab.table.hasClass('move')).to.be.true
			tab.stopTable pageX: 0, pageY: 0, data: {maxX: 30, maxY: 50}
			expect(tab.table.hasClass('move')).to.be.false

	describe 'method getConnPoints', ->
		obj = null
		before ->
			tab = new Table canvas, 'id', 20, 30, 160, 300
			obj = tab.getConnPoints()

		it 'should return object containing connection point for each side', -> 
			expect(obj).to.be.an('object')
			.and.have.keys ['top', 'right', 'bottom', 'left']
			
		it 'should have x and y coordinates for each connection point', ->
			expect(obj.top).to.have.keys ['x', 'y']
			expect(obj.right).to.have.keys ['x', 'y']
			expect(obj.bottom).to.have.keys ['x', 'y']
			expect(obj.left).to.have.keys ['x', 'y']

		it 'should count correct connection points positions', ->
			expect(obj.top).to.have.deep.equal x: 100, y: 30
			expect(obj.right).to.have.deep.equal x: 181, y: 180
			expect(obj.bottom).to.have.deep.equal x: 100, y: 331
			expect(obj.left).to.have.deep.equal x: 20, y: 180

		it 'should count points for each table separetlly', ->
			tab2 = new Table canvas, 'id2', 78, 69, 75, 205
			obj2 = tab2.getConnPoints()
			expect(obj).to.not.deep.equal obj2

	describe 'method addRelation', ->
		it 'should add relations to table', ->
			tab = new Table canvas, 'i', 10, 10
			
			expect(tab.relations).to.be.empty

			tab.addRelation 'rel1'
			tab.addRelation 'rel2'
			tab.addRelation 'rel3'

			expect(tab.relations).to.have.length(3).and.deep.equal ['rel1','rel2','rel3']

		it 'should set clear list of table\'s relations for each new table', ->
			tab1 = new Table canvas, 'i', 20, 30
			
			tab1.addRelation 'rel2'
			tab1.addRelation 'rel5'
			expect(tab1.relations).to.have.length(2).and.deep.equal ['rel2','rel5']

			tab3 = new Table canvas, 'd', 40, 50
			expect(tab3.relations).to.be.an('array').and.be.empty
Table = require "#{srcDir}/components/model/table"
tab = null
canvas = $('canvas')

describe 'class Table', ->
	describe 'constructor', ->
		before ->
			tab = new Table canvas, 70, 50

		it 'should have position properties with null value', ->
			tab.should.have.deep.property 'position.relative.x', null
			tab.should.have.deep.property 'position.relative.y', null
			tab.should.have.deep.property 'position.absolute.x', null
			tab.should.have.deep.property 'position.absolute.y', null

		it 'should create table object with header', ->
			expect(tab.table.hasClass('table')).to.be.true
			expect(tab.table.children('input.head')).to.have.length 1

		it 'should have passed x and y as proerties left and top', ->
			expect(tab.table.css('left')).to.equal '70px'
			expect(tab.table.css('top')).to.equal '50px'

		it 'should set default size if no passed', ->
			expect(tab.table.width()).to.equal 100
			expect(tab.table.height()).to.equal 80

		it 'should set the size if passed', ->
			tab2 = new Table canvas, 0, 0, 40, 120
			expect(tab2.table.width()).to.equal 40
			expect(tab2.table.height()).to.equal 120
	
	describe 'startTable', ->
		fakeEv = pageX: 110, pageY: 230
		mPos = null

		before ->
			tab = new Table canvas, 0, 0
			mPos = sinon.stub(tab.table, 'position').returns left: 60, top: 100

		after ->
			mPos.reset()

		it 'should set position and relative coordinates', ->
			tab.startTable fakeEv
			tab.position.relative.should.deep.equal x: 60, y: 100
			tab.position.absolute.should.deep.equal x: 110, y: 230

	describe 'moveTable', ->
		fakeEv = pageX: 100, pageY: 150, data: {maxX: 300, maxY: 500}
		startEv = pageX: 100, pageY: 150
		mPos = null
		mCss = null

		before ->
			tab = new Table canvas, 20, 20, 70, 50
			mPos = sinon.stub(tab.table, 'position').returns left: 20, top: 30
			mCss = sinon.stub(tab.table, 'css')

		after ->
			mPos.reset()
			mCss.reset()	

		it 'should add class `move` to table', ->
			tab.moveTable pageX: 0, pageY: 0
			expect(tab.table.hasClass('move')).to.be.true

		it 'should count correct coordinates when imputing coordintes', ->
			tab.startTable startEv
			fakeEv.pageX = 130
			fakeEv.pageY = 175
			tab.moveTable fakeEv

			# 20 + (130 -100) and 30 + (175 - 150)
			mCss.should.been.calledWithExactly left: 50, top: 55 

		it 'should count correct coordinates when subtracting coordintes', ->
			tab.startTable startEv
			fakeEv.pageX = 90
			fakeEv.pageY = 125
			tab.moveTable fakeEv

			# 20 + (90 -100) and 30 + (125 - 150)
			mCss.should.been.calledWithExactly left: 10, top: 5

		it 'should set coords to canvas max minus table size if table is outside canvas', ->
			tab.startTable startEv
			fakeEv.pageX = 460
			fakeEv.pageY = 690
			tab.moveTable fakeEv

			# 20 + (460 -100 - 70) = 310  and 30 + (690 - 150 - 50) = 520
			# x max is 300 - 70 = 230 and y max is 500 - 50 = 450
			mCss.should.been.calledWithExactly left: 230, top: 450	 	

		it 'should set coords to canvas min if coords are lower than min', ->
			tab.startTable startEv
			fakeEv.pageX = 30
			fakeEv.pageY = 100
			tab.moveTable fakeEv

			# 20 + (30 -100) = -50  and 30 + (100 - 150) = -20
			mCss.should.been.calledWithExactly left: 0, top: 0

	describe 'stopTable', ->
		before ->
			tab = new Table canvas, 0, 0

		it 'should remove class `move` from table', ->
			tab.moveTable pageX: 0, pageY: 0
			expect(tab.table.hasClass('move')).to.be.true
			tab.stopTable pageX: 0, pageY: 0
			expect(tab.table.hasClass('move')).to.be.false 	

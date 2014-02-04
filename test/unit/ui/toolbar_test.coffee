goog.require 'dm.ui.Toolbar'
goog.require 'dm.ui.tools.CreateTable'

describe 'module Toolbar', ->

describe 'module CreateTable', ->
	gsz = null
	cta = null
	ev = null

	before ->
		gsz = sinon.stub(goog.style, 'getSize').returns width: 30, height: 50
		cta = new dm.ui.tools.CreateTable
		cta.areaSize = width: 500, height: 340

	after ->
		gsz.restore()

	describe 'moveTable', ->
		grp = null
		spos = null
		gop = null

		before -> 
			grp = sinon.stub goog.style, 'getRelativePosition'
			spos = sinon.stub goog.style, 'setPosition'
			gop = sinon.stub goog.style, 'getOffsetParent'

			cta.table = 'table'

		beforeEach ->
			grp.reset()
			spos.reset()
			gop.reset()
			gsz.reset()

		
		after ->
			grp.restore()
			spos.restore()
			gop.restore()

		it 'should set position to min if position is less than canvas min', ->
			grp.returns x: -245, y: -160

			cta.moveTable ev

			spos.should.been.calledOnce
			spos.should.been.calledWithExactly 'table', 0, 0

		it 'should set position to max if position is greater than canvas max', ->
			grp.returns x: 562, y: 402

			cta.moveTable ev

			spos.should.been.calledOnce
			spos.should.been.calledWithExactly 'table', 468, 288

		it 'should count position of table and set it', ->
			grp.returns x: 345, y: 268

			cta.moveTable ev

			spos.should.been.calledOnce
			spos.should.been.calledWithExactly 'table', 345, 268

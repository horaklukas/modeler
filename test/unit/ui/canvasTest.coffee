goog.require 'dm.ui.Canvas'
goog.require 'goog.events.Event'

describe 'class Canvas', ->
	can = null
	ev = null

	before ->
		rootElem = document.createElement 'div'
		rootElem.id = 'rootElem'
		document.body.appendChild rootElem

		can = new dm.ui.Canvas()
		ev = new goog.events.Event()
		can.render rootElem

	describe 'constructor', ->
		it 'should init properties for hold moving object', ->
			can.should.have.deep.property 'move.object', null
			can.should.have.deep.property 'move.offset', null 

	describe 'enterDocument', ->
		parentElement = null	
		can2 = null

		before ->
			parentElement = document.createElement 'div'
			parentElement.style.setProperty 'width', '600px'
			parentElement.style.setProperty 'height', '300px'
			document.body.appendChild parentElement

		beforeEach ->
			can2 = new dm.ui.Canvas()

		it 'should set size information taken from canvas element', ->
			can2.render parentElement

			can2.should.have.deep.property 'size_.width', 600
			can2.should.have.deep.property 'size_.height', 300

		it 'should create and save clue table', ->
			can2.render parentElement

			can2.should.have.property 'clueTable'
			styles = can2.clueTable.style.cssText
			expect(styles).to.contain 'display: none'
			expect(styles).to.contain 'top: 0'
			expect(styles).to.contain 'left: 0'

	describe 'method onDblClick', ->
		goibe = null
		gch = null
		die = null

		before ->
			goibe = sinon.stub can, 'getObjectIdByElement'
			gch = sinon.stub can, 'getChild'
			die = sinon.stub can, 'dispatchEvent'

		beforeEach ->
			goibe.reset()
			gch.reset()
			die.reset()

		after ->
			goibe.restore()
			gch.restore()
			die.restore()

		it 'should return false if target element is canvas div wrapper', ->
			ev.target = can.rootElement_
			
			expect(can.onDblClick ev).to.be.false

		it 'should get right child object and dispatch event with it', ->
			ev.target = 'some div'
			goibe.withArgs('some div').returns 'object'
			gch.withArgs('object').returns 'fakeobject'

			can.onDblClick ev

			die.should.been.calledOnce
			die.lastCall.args[0].should.have.property 'target', 'fakeobject'

	describe 'onCaughtTable', ->
		it 'should save object start moving data', ->
			ev.target = 'tableObject'
			ev.catchOffset = x: 34, y: 65

			can.onCaughtTable ev

			can.should.have.deep.property 'move.object', 'tableObject'
			can.should.have.deep.property('move.offset').that.deep.equal x: 34, y: 65

	describe 'moveTable', ->
		grp = null

		before -> 
			grp = sinon.stub goog.style, 'getRelativePosition'
			can.move.object = 
				setPosition: sinon.stub()
				getSize: sinon.stub().returns width: 30, height: 50
				dispatchEvent: sinon.spy()

		beforeEach ->
			grp.reset()
			can.move.object.setPosition.reset()
			can.move.offset = x: 0, y: 0
			can.size_ = width: 500, height: 340
		
		after ->
			grp.restore()

		it 'should set position to min if position is less than canvas min', ->
			grp.returns x: -245, y: -160
			can.move.offset = x: 5, y: 40

			can.moveTable ev

			can.move.object.setPosition.should.been.calledOnce
			can.move.object.setPosition.should.been.calledWithExactly 0, 0

		it 'should set position to max if position is greater than canvas max', ->
			grp.returns x: 562, y: 402
			can.move.offset = x: 35, y: 40

			can.moveTable ev

			can.move.object.setPosition.should.been.calledOnce
			can.move.object.setPosition.should.been.calledWithExactly 470, 290

		it 'should count position of table and set it', ->
			grp.returns x: 345, y: 268
			can.move.offset = x: 34, y: 65

			can.moveTable ev

			can.move.object.setPosition.should.been.calledOnce
			can.move.object.setPosition.should.been.calledWithExactly 311, 203

	describe 'getObjectIdByElement', ->
		it 'should return null if passed canvas element', ->
			expect(can.getObjectIdByElement can.rootElement_).to.be.null

		it 'should return id if passed root element of object', ->
			rootElement = document.createElement 'div'
			rootElement.id = 'elemid'
			can.rootElement_.appendChild rootElement 

			expect(can.getObjectIdByElement rootElement).to.equal 'elemid'

		it 'should return id if passed any deeper element of object', ->
			innerElement1 = document.createElement 'div'
			innerElement1.id = 'inner1'
			innerElement2 = document.createElement 'div'
			#innerElement2.id = 'inner2'
			innerElement3 = document.createElement 'div'
			#innerElement3.id = 'inner3'

			innerElement2.appendChild innerElement3 
			innerElement1.appendChild innerElement2 
			can.rootElement_.appendChild innerElement1

			expect(can.getObjectIdByElement innerElement3).to.equal 'inner1'
goog.require 'dm.dialogs.RelationDialog'

global.DB = types: [] 

describe 'class RelationDialog', ->
	reld = null

	before ->
		reld = dm.dialogs.RelationDialog.getInstance()

	describe 'method setIdentifying', ->
		it 'should save identifying as a boolean value', ->
			reld.setIdentifying target: value: '0'
			reld.isIdentifying.should.be.false

			reld.setIdentifying target: value: '1'
			reld.isIdentifying.should.be.true

	describe 'method swapTables', ->
		ev = preventDefault: sinon.spy(), target: null
		gebc = null
		parent = null
		child = null

		before ->
			gebc = sinon.stub goog.dom, 'getElementByClass'
			parent = document.createElement 'div'
			child = document.createElement 'div'
			gebc.withArgs('parent').returns parent
			gebc.withArgs('child').returns child

		beforeEach ->
			reld.tablesSwaped = false
			parent.innerHTML = 'Parent name'
			child.innerHTML = 'Child name'
			ev.preventDefault.reset()
			gebc.reset()

		after ->
			gebc.restore()

		it 'should toggle swapped table flag', ->
			reld.swapTables ev

			reld.tablesSwaped.should.be.true
			
		it 'should swap content text inside child and parent', ->
			reld.swapTables ev

			parent.textContent.should.equal 'Child name'
			child.textContent.should.equal 'Parent name'

	describe 'method show', ->
		setvis = null
		setval = null
		isIdent = sinon.stub()
		getParentName = sinon.stub()
		getChildName = sinon.stub()
		rel = 
			getModel: -> isIdentifying: isIdent
			parentTab: getModel: -> getName: getParentName 
			childTab: getModel: -> getName: getChildName 

		before ->
			setvis = sinon.stub reld, 'setVisible'
			setval = sinon.stub reld, 'setValues'

		beforeEach ->
			isIdent.reset()
			getParentName.reset()
			getChildName.reset()
			setvis.reset()
			setval.reset()

		after ->
			setvis.restore()
			setval.restore()

		it 'should only show/hide if relation object not passed', ->
			reld.show true
			reld.show false

			isIdent.should.not.been.called
			getParentName.should.not.been.called
			getChildName.should.not.been.called

		it 'should show dialog if passed true', ->
			reld.show true

			setvis.should.been.calledWithExactly true

		it 'should hide dialog if passed false', ->
			reld.show false

			setvis.should.been.calledWithExactly false

		it 'should set identifying flag', ->
			isIdent.returns true
			reld.show true, rel
			reld.isIdentifying.should.be.true

			isIdent.returns false
			reld.show true, rel
			reld.isIdentifying.should.be.false

		it 'should set values from passed relation to dialog', ->
			getParentName.returns 'table1'
			getChildName.returns 'table2'
			isIdent.returns true

			reld.show true, rel

			setval.should.been.calledOnce.and.calledWithExactly 'table1', 'table2', true
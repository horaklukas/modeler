goog.require 'dm.ui.Table'
goog.require 'goog.events.EventTarget'

describe 'class Table', ->
	tab = null
	fakeModel = null 
	
	before ->		
		fakeModel = new goog.events.EventTarget()
		fakeModel.getName = sinon.stub()
		fakeModel.getColumns = sinon.stub()

		tab = new dm.ui.Table fakeModel

	describe 'constructor', ->
		it 'should save passed model', ->
			expect(tab).to.have.property 'model_', fakeModel

		it 'should init position at 0,0 if coordinates not passed', ->
			expect(tab).to.have.deep.property 'position_.x', 0
			expect(tab).to.have.deep.property 'position_.y', 0

		it 'should init position at passed coordinates', ->
			tab2 = new dm.ui.Table fakeModel, 34, 265

			expect(tab2).to.have.deep.property 'position_.x', 34
			expect(tab2).to.have.deep.property 'position_.y', 265

	describe 'method createDom', ->
		gm = null
		gi = null
		sei = null

		before ->
			gm = sinon.stub tab, 'getModel'
			gi = sinon.stub tab, 'getId'
			sei = sinon.stub tab, 'setElementInternal'

		beforeEach ->
			gm.reset()
			gi.reset()
			sei.reset()

		after ->
			gm.restore()
			gi.restore()
			sei.restore()

		it 'should save created element', ->
			fakeModel.getName.returns ''
			fakeModel.getColumns.returns []
			gm.returns fakeModel
			gi.returns 123

			tab.createDom()

			sei.should.been.calledOnce.and
			sei.lastCall.args[0].should.be.truthy

		it 'should save table name to its head', ->
			fakeModel.getName.returns 'TAB1'
			gm.returns fakeModel

			tab.createDom()

			expect(tab).to.have.deep.property 'head_.innerHTML', 'TAB1'
			expect(tab).to.have.deep.property 'head_.className', 'head'

		it 'should save table name to its body', ->
			fakeModel.getName.returns ''
			fakeModel.getColumns.returns [{name: 'col1', isPk: false}]
			gi.returns 'i1d'
			gm.returns fakeModel

			tab.createDom()

			expect(tab).to.have.deep.property 'body_.className', 'body'			

	describe 'method setPosition', ->
		iid = null
		ssp = null

		before -> 
			iid = sinon.stub tab, 'isInDocument'
			ssp = sinon.stub goog.style, 'setPosition' 

		beforeEach ->
			iid.reset()
			ssp.reset()
		
		after ->
			iid.restore()
			ssp.restore()

		it 'should set new table position', ->
			tab.setPosition 69, 96

			expect(tab).to.have.deep.property 'position_.x', 69
			expect(tab).to.have.deep.property 'position_.y', 96

		it 'should set position of element if it is in document already', ->
			iid.returns true
			tab.setPosition 14, 41

			ssp.should.been.calledOnce
			ssp.lastCall.args[1].should.equal 14
			ssp.lastCall.args[2].should.equal 41

	describe.skip 'method getConnPoints', ->
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

	describe 'method addColumn', ->
		before ->
			tab = new dm.ui.Table fakeModel

		it 'should add column to the end of columns', ->
			fakeModel.getColumns.returns {
				'id1': {name: 'col1', isPk: false}, 'id2': {name: 'col2', isPk: true}
			}
			tab.createDom()
			# one more node is tabulator before column nodes
			expect(tab).to.have.deep.property 'body_.childNodes.length', 3

			tab.addColumn 'id3', {name: 'col3', isPk: true}

			expect(tab).to.have.deep.property 'body_.childNodes.length', 4

	describe 'method updateColumn', ->
		before ->
			tab = new dm.ui.Table fakeModel

		beforeEach ->
			fakeModel.getColumns.returns {
				'id1': {name: 'col3', isPk: false}, 'id2': {name: 'col4', isPk: false}
				'id3': {name: 'col5', isPk: true}
			}
			tab.createDom()

		it 'should left count of columns same as it was', ->
			# one more node is tabulator before column nodes
			expect(tab).to.have.deep.property 'body_.childNodes.length', 4

			tab.updateColumn 'id1', {name: 'col3', isPk: true}

			expect(tab).to.have.deep.property 'body_.childNodes.length', 4

		it 'should replace old column element with new column element', ->
			# one more node is tabulator before column nodes
			expect(tab).to.have.deep.property 'body_.childNodes[2]'
			expect(goog.dom.getTextContent tab.body_.childNodes[2]).to.equal 'col4'

			tab.updateColumn 'id2', {name: 'col6', isPk: false}

			expect(goog.dom.getTextContent tab.body_.childNodes[2]).to.equal 'col6'

	describe 'method removeColumn', ->
		before ->
			tab = new dm.ui.Table fakeModel

		beforeEach ->
			fakeModel.getColumns.returns [
				{name: 'col1', isPk: false}, {name: 'col2', isPk: false}
				{name: 'col3', isPk: false}, {name: 'col4', isPk: true}
			]

			tab.createDom()

		it 'should remove one column element', ->
			# one more node is tabulator before column nodes
			expect(tab).to.have.deep.property 'body_.childNodes.length', 5

			tab.removeColumn 2

			expect(tab).to.have.deep.property 'body_.childNodes.length', 4

		it 'should remove column with passed index', ->
			# one more node is tabulator before column nodes
			expect(tab).to.have.deep.property 'body_.childNodes[2]'
			expect(goog.dom.getTextContent tab.body_.childNodes[2]).to.equal 'col2'

			tab.removeColumn 1

			expect(goog.dom.getTextContent tab.body_.childNodes[2]).to.equal 'col3'

goog.require 'dm.model.Table'

describe 'class Table', ->
	tab = null
	spy = sinon.spy()

	before ->
		tab = new dm.model.Table()

	describe 'method setName', ->
		it 'should set empty table name if not passed', ->
			tab.setName()
			expect(tab).to.have.property 'name_', ''

		it 'should save passed name', ->
			tab.setName 'tablename'
			expect(tab).to.have.property 'name_', 'tablename'			

	describe 'method setColumn', ->
		beforeEach ->
			tab.columns_ = [
					{name: 'one', type: 'char'}
					{name: 'second', type: 'varchar'}
					{name: 'three', type: 'number'}
				]
			tab.indexes = {}

			spy.reset()

		it 'should save column to passed index', ->
			expect(tab.columns_[1]).to.have.property 'name', 'second'
			tab.setColumn {name: 'another second', type: null}, 1

			expect(tab.columns_[1]).to.have.property 'name', 'another second'

		it 'should save column to end if index not passed', ->
			expect(tab.columns_[3]).to.not.exist
			tab.setColumn {name: 'four', type: 'char'}, null
			
			expect(tab.columns_[3]).to.exist.and.have.property 'name', 'four'

		it 'should dispatch `column-change` event if passed column index', ->
			goog.events.listenOnce tab, 'column-change', spy

			tab.setColumn {name: 'sixty', type: 'sly'}, 34 

			spy.should.been.calledOnce
			spy.lastCall.args[0].should.have.deep.property('column.data').that
				.deep.equal {name: 'sixty', type: 'sly'}
			spy.lastCall.args[0].should.have.deep.property 'column.index', 34

		it 'should set indexes for column if exists at model', ->
			tab.indexes['four'] = 'fk'
			goog.events.listenOnce tab, 'column-change', spy
			
			tab.setColumn {name: 'four', type: 'char'}, 3
			
			spy.should.been.calledOnce
			spy.lastCall.args[0].should.have.deep.property('column.data.indexes').that.eql 'fk'

		it 'should not set indexes for column if not exists at model', ->
			tab.indexes['two'] = 'fk'
			goog.events.listenOnce tab, 'column-change', spy
			
			tab.setColumn {name: 'three', type: 'varchar'}, 2
			
			spy.should.been.calledOnce
			spy.lastCall.args[0].should.not.have.deep.property 'column.data.indexes'

		it 'should dispatch `column-add` event if not passed column index', ->
			goog.events.listenOnce tab, 'column-add', spy

			tab.setColumn {name: 'seventy', type: 'arnie'}

			spy.should.been.calledOnce
			spy.lastCall.args[0].should.have.deep.property('column.data').that
				.deep.equal {name: 'seventy', type: 'arnie'}
			spy.lastCall.args[0].should.not.have.deep.property 'column.index'

		it 'should return id of new column', ->
			expect(tab.setColumn {name: 'four', type: 'char'}).to.equal 3

	describe 'method removeColumn', ->
		beforeEach ->
			tab.columns_ = [
				{name: 'one', type: 'char'}
				{name: 'second', type: 'varchar'}
				{name: 'three', type: 'number'}
			]

			spy.reset()

		it 'should remove column with given index', ->
			expect(tab.columns_).to.have.property(1).that.deep.equal {name: 'second', type: 'varchar'}

			tab.removeColumn 1

			tab.columns_.should.have.property 'length', 2
			expect(tab.columns_).to.have.property(1).that.deep.equal {name: 'three', type: 'number'}

		it 'should dispatch `column-delete` with index of column to delete', ->
			goog.events.listenOnce tab, 'column-delete', spy

			tab.removeColumn 2

			spy.should.been.calledOnce
			spy.lastCall.args[0].should.to.have.deep.property 'column.index', 2 
			spy.lastCall.args[0].should.have.deep.property 'column.data', null

	describe 'method getColumnById', ->
		beforeEach ->
			tab.columns_ = [
				{name: 'one', type: 'char'}
				{name: 'second', type: 'varchar'}
			]		

		it 'should return null if index not passed', ->
			expect(tab.getColumnById()).to.be.null

		it 'return null if column with passed index not exist', ->
			expect(tab.getColumnById 3).to.be.null

		it 'return column with passed index if exists', ->
			expect(tab.getColumnById 1).to.deep.equal name: 'second', type: 'varchar'

	describe 'method getColumnByName', ->
		before ->
			tab.columns_ = [
				{name: 'one', type: 'char'}
				{name: 'second', type: 'varchar'}
				{name: 'third', type: 'number'}
				{name: 'fourth', type: 'varchar'}
			]		

		it 'should return null if column with passed name not exist', ->
			expect(tab.getColumnByName('fifth')).to.be.null

		it 'return column with passed name if exists', ->
			expect(tab.getColumnByName 'third').to.deep.equal {name: 'third', type: 'number'}

	describe 'method setIndex', ->
		gcbi = null
		diev = null

		before ->
			gcbi = sinon.stub tab, 'getColumnById'
			diev = sinon.stub tab, 'dispatchEvent'

		beforeEach ->
			tab.indexes = {}
			gcbi.reset()
			diev.reset()

		after ->
			gcbi.restore()
			diev.restore()

		it 'should create list of indexes if it not exist yet', ->
			tab.setIndex 3, 'fk'

			tab.indexes.should.have.property(3).that.is.an.array
			tab.indexes[3].should.eql ['fk']

		it 'should insert index into list of indexes if index isnt there', ->
			tab.indexes[1] = ['fk']

			tab.setIndex 1, 'pk'

			tab.indexes[1].should.eql ['fk','pk']

		it 'should not insert index to list of indexes if index is there', ->	
			tab.indexes[0] = ['pk', 'fk']

			tab.setIndex 0, 'pk'
			tab.setIndex 0, 'fk'

			tab.indexes[0].should.eql ['pk','fk']

		it 'should remove index if passed third parameter true', ->
			tab.indexes[3] = ['pk', 'fk', 'unq']

			tab.setIndex 3, 'fk', true

			tab.indexes[3].should.eql ['pk', 'unq']

describe 'class ColumnsChange', ->
	describe 'constructor', ->
		it 'should be `column-add` type if passed only column, not index', ->
			ev = new dm.model.Table.ColumnsChange 'column'

			ev.should.have.property 'type', 'column-add'

		it 'should be `column-change` type if passed column and index', ->
			ev = new dm.model.Table.ColumnsChange 'column', 3

			ev.should.have.property 'type', 'column-change'
			
		it 'should be `column-delete` type if passed only index, not column', ->
			ev = new dm.model.Table.ColumnsChange null, 4

			ev.should.have.property 'type', 'column-delete'
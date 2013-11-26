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

		it 'should dispatch `column-add` event if not passed column index', ->
			goog.events.listenOnce tab, 'column-add', spy

			tab.setColumn {name: 'seventy', type: 'arnie'}

			spy.should.been.calledOnce
			spy.lastCall.args[0].should.have.deep.property('column.data').that
				.deep.equal {name: 'seventy', type: 'arnie'}
			spy.lastCall.args[0].should.not.have.deep.property 'column.index'

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
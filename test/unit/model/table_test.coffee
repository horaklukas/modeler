goog.require 'dm.model.Table'

describe.skip 'class model.Table', ->
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
		before ->
			sinon.stub tab, 'getColumnByName'

		beforeEach ->
			tab.columns_ = [
					{name: 'one', type: 'char'}
					{name: 'second', type: 'varchar'}
					{name: 'three', type: 'number'}
				]
			tab.indexes = {}

			spy.reset()
			tab.getColumnByName.reset()
			tab.getColumnByName.returns null

		after ->
			tab.getColumnByName.restore()

		it 'should add suffix to column name if new column\'s name exists', ->
			tab.getColumnByName.returns tab.columns_[2]
			tab.setColumn {name: 'three', type: null}

			expect(tab.columns_[3]).to.exist.and.have.property 'name', 'three_0'

		it 'should add suffix to col name if updated column\'s name has another column ', ->
			tab.getColumnByName.returns tab.columns_[0]
			tab.setColumn {name: 'one', type: 'number'}, 2

			expect(tab.columns_[2]).to.have.property 'name', 'one_0'

		it 'should not add suffix if updated column but name not change', ->
			expect(tab.columns_[1]).to.have.property 'type', 'varchar'
			tab.getColumnByName.returns tab.columns_[1]

			tab.setColumn {name: 'other', type: 'number'}, 1

			expect(tab.columns_[1]).to.have.property 'name', 'other'
			expect(tab.columns_[1]).to.have.property 'type', 'number'

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

			tab.columns_.should.have.length 2
			expect(tab.columns_).to.have.property(1).that.deep.equal {name: 'three', type: 'number'}

		it 'should remove indexes that belongs to column for delete', ->
			tab.indexes = {
				'0': ['pk', 'fk']
				'1': ['unq']
				'2': ['pk']
			}

			tab.removeColumn 1

			tab.columns_.should.have.length 2
			tab.indexes.should.have.keys ['0', '2']
			tab.indexes.should.not.have.keys ['1']

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

	describe 'method getColumnsIdsByIndex', ->
		beforeEach ->
			tab.indexes = {}

		it 'should return array of ids that has passed index', ->
			tab.indexes = {
				1: ['unq', 'fk'], 2: ['pk'], 3: ['unq'], 4: ['fk']
			}

			expect(tab.getColumnsIdsByIndex('unq')).to.deep.equal [1, 3]

		it 'should return empty array if no column has passed index', ->
			tab.indexes = {
				1: ['unq'], 2: ['fk'], 3: ['unq', 'fk'] 
			}
			pks = tab.getColumnsIdsByIndex('pk')

			expect(pks).to.be.an.array
			expect(pks).to.be.empty

	describe 'method toJSON', ->
		before ->
			sinon.stub(tab, 'getColumnsIdsByIndex').returns []

		beforeEach ->
			tab.name_ = 'table1'
			tab.columns_ = [
				{name: 'one', type: 'char'}
				{name: 'second', type: 'varchar'}
				{name: 'third', type: 'number'}
			]
			tab.indexes = 1: ['unq', 'fk'], 2: ['pk'], 3: ['unq']
			tab.getColumnsIdsByIndex.reset()

		after ->
			tab.getColumnsIdsByIndex.restore()

		it 'should retunn JSON like representation of model', ->
			json = tab.toJSON()

			expect(json).to.have.property 'name', 'table1'
			expect(json).to.have.deep.property 'columns[0].name', 'one'
			expect(json).to.have.deep.property 'columns[1].name', 'second'
			expect(json).to.have.deep.property 'columns[2].name', 'third'
			expect(json).to.have.deep.property('indexes[1]').that.deep.equal ['unq', 'fk']
			expect(json).to.have.deep.property('indexes[2]').that.deep.equal ['pk']
			expect(json).to.have.deep.property('indexes[3]').that.deep.equal ['unq']

		it 'should filter foreign key columns', ->
			tab.getColumnsIdsByIndex.returns [0]

			json = tab.toJSON()
			expect(json.columns).to.be.an('array').and.have.length 2
			expect(json).to.have.deep.property 'columns[0].name', 'second'
			expect(json).to.have.deep.property 'columns[1].name', 'third'

describe 'class ColumnsChange', ->
	describe 'constructor', ->
		it 'should be `column-add` type if passed true as a third param', ->
			ev = new dm.model.Table.ColumnsChange 'column', 'id1', true

			ev.should.have.property 'type', 'column-add'

		it 'should be `column-change` type if passed false as a third param', ->
			ev = new dm.model.Table.ColumnsChange 'column', 'id1', false
			ev.should.have.property 'type', 'column-change'

			ev = new dm.model.Table.ColumnsChange 'column', 'id3'
			ev.should.have.property 'type', 'column-change'
			
		it 'should be `column-delete` type if column not passed', ->
			ev = new dm.model.Table.ColumnsChange null, 'id2'

			ev.should.have.property 'type', 'column-delete'
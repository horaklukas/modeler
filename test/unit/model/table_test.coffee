goog.require 'dm.model.Table'

describe 'class model.Table', ->
	tab = null
	spy = sinon.spy()

	before ->
		tab = new dm.model.Table()

	describe 'method setName', ->
		it 'should set empty table name if not passed', ->
			tab.setName()
			expect(tab).to.have.property 'name', ''

		it 'should save passed name', ->
			tab.setName 'tablename'
			expect(tab).to.have.property 'name', 'tablename'			

	describe 'method setColumn', ->
		before ->
			sinon.stub tab, 'getColumnByName'
			sinon.stub tab, 'getUniqueColumnName'
			@getId = sinon.stub goog.ui.IdGenerator.getInstance(), 'getNextUniqueId'

		beforeEach ->
			tab.columns = 
				'id1': {name: 'one', type: 'char'}
				'id2': {name: 'second', type: 'varchar'}
				'id3': {name: 'three', type: 'number'}
				'id3_0': {name: 'three_0', type: 'number'}
	
			tab.indexes = {}

			spy.reset()
			tab.getColumnByName.reset()
			tab.getColumnByName.returns null
			tab.getUniqueColumnName.returns null
			@getId.returns 'id4'

		after ->
			tab.getColumnByName.restore()
			tab.getUniqueColumnName.restore()
			@getId.restore()

		it 'should set unique name to column for new column', ->
			tab.getUniqueColumnName.withArgs('three').returns 'three_1'
			tab.setColumn {name: 'three', type: null}

			expect(tab.columns['id4']).to.exist.and.have.property 'name', 'three_1'

		it 'should set new unique name for updated column', ->
			tab.getUniqueColumnName.withArgs('second').returns 'second_0'
			tab.setColumn {name: 'second', type: 'number'}, 'id3'

			expect(tab.columns['id3']).to.have.property 'name', 'second_0'

		it 'should left original update column name if it not change', ->
			tab.getUniqueColumnName.withArgs('threeses').returns 'threeses'
			tab.setColumn {name: 'threeses', type: 'varchar'}, 'id3'

			expect(tab.columns['id3']).to.have.property 'name', 'threeses'

		it 'should save column to passed id', ->
			tab.getUniqueColumnName.withArgs('another second').returns 'another second'
			expect(tab.columns['id2']).to.have.property 'name', 'second'
			tab.setColumn {name: 'another second', type: null}, 'id2'

			expect(tab.columns['id2']).to.have.property 'name', 'another second'

		it 'should save column to end if id not passed', ->
			tab.getUniqueColumnName.withArgs('four').returns 'four'
			expect(tab.columns['id4']).to.not.exist
			tab.setColumn {name: 'four', type: 'char'}, null
			
			expect(tab.columns['id4']).to.exist.and.have.property 'name', 'four'

		it 'should dispatch `column-change` event if passed column id', ->
			tab.getUniqueColumnName.withArgs('sixty').returns 'sixty'
			goog.events.listenOnce tab, 'column-change', spy

			tab.setColumn {name: 'sixty', type: 'sly'}, 'id35' 

			spy.should.been.calledOnce
			spy.lastCall.args[0].should.have.deep.property('column.data').that
				.deep.equal {name: 'sixty', type: 'sly'}
			spy.lastCall.args[0].should.have.deep.property 'column.id', 'id35'

		it 'should set indexes for column if exists at model', ->
			tab.indexes['id3'] = 'fk'
			goog.events.listenOnce tab, 'column-change', spy
			
			tab.setColumn {name: 'four', type: 'char'}, 'id3'
			
			spy.should.been.calledOnce
			spy.lastCall.args[0].should.have.deep.property('column.data.indexes').that.eql 'fk'

		it 'should not set indexes for column if not exists at model', ->
			tab.indexes['id2'] = 'fk'
			goog.events.listenOnce tab, 'column-change', spy
			
			tab.setColumn {name: 'three', type: 'varchar'}, 'id3'
			
			spy.should.been.calledOnce
			spy.lastCall.args[0].should.not.have.deep.property 'column.data.indexes'

		it 'should dispatch `column-add` event if not passed column id', ->
			tab.getUniqueColumnName.withArgs('seventy').returns 'seventy'
			goog.events.listenOnce tab, 'column-add', spy

			tab.setColumn {name: 'seventy', type: 'arnie'}

			spy.should.been.calledOnce
			spy.lastCall.args[0].should.have.deep.property('column.data').that
				.deep.equal {name: 'seventy', type: 'arnie'}
			spy.lastCall.args[0].should.have.deep.property 'column.id', 'id4'

		it 'should return id of new column', ->
			expect(tab.setColumn {name: 'four', type: 'char'}).to.equal 'id4'

	describe 'method getUniqueColumnName', ->
		before ->
			sinon.stub tab, 'getColumnByName'

		beforeEach ->
			tab.columns = 
				'id1': {name: 'one', type: 'char'}
				'id1_0': {name: 'one_0', type: 'char'}
				'id1_1': {name: 'one_1', type: 'char'}
				'id2': {name: 'second', type: 'varchar'}
				'id3': {name: 'three', type: 'number'}

			tab.getColumnByName.reset()

		after ->
			tab.getColumnByName.restore()

		it 'should not add suffix to column name if column\'s name not exists', ->
			tab.getColumnByName.withArgs('four').returns null

			expect(tab.getUniqueColumnName 'four').to.equal 'four'

		it 'should add suffix to column name if column\'s name exists', ->
			tab.getColumnByName.withArgs('three').returns tab.columns['id3']

			expect(tab.getUniqueColumnName 'three').to.equal 'three_0'

		it 'should increment suffixes until column name is unique', ->
			tab.getColumnByName.withArgs('one').returns tab.columns['id1']
			tab.getColumnByName.withArgs('one_0').returns tab.columns['id1_0']
			tab.getColumnByName.withArgs('one_1').returns tab.columns['id1_1']
			
			expect(tab.getUniqueColumnName 'one').to.equal 'one_2'

		it 'should add suffix if another column has name of updating column', ->
			tab.getColumnByName.withArgs('second').returns tab.columns['id2']

			expect(tab.getUniqueColumnName 'second', 'id3').to.equal 'second_0'

		it 'should not add suffix if column name is unique (has it column inself only)', ->
			expect(tab.columns['id2']).to.have.property 'type', 'varchar'
			tab.getColumnByName.withArgs('second').returns tab.columns['id2']

			expect(tab.getUniqueColumnName 'second', 'id2').to.equal 'second'

	describe 'method removeColumn', ->
		beforeEach ->
			tab.columns = 
				'id1': {name: 'one', type: 'char'}
				'id2': {name: 'second', type: 'varchar'}
				'id3': {name: 'three', type: 'number'}

			spy.reset()

		it 'should remove column with given id', ->
			expect(tab.columns).to.have.property('id2').that.deep.equal {
				name: 'second', type: 'varchar'
			}

			tab.removeColumn 'id2'

			expect(tab.columns).to.not.have.property 'id2'
			tab.columns.should.have.keys ['id1', 'id3']

		it 'should remove indexes that belongs to column for delete', ->
			tab.indexes =
				'id1': ['pk', 'fk']
				'id2': ['unq']
				'id3': ['pk']

			tab.removeColumn 'id2'

			tab.columns.should.have.keys ['id1', 'id3']
			tab.indexes.should.have.keys ['id1', 'id3']
			tab.indexes.should.not.have.keys ['id2']

		it 'should dispatch `column-delete` with id of column to delete', ->
			goog.events.listenOnce tab, 'column-delete', spy

			tab.removeColumn 'id2'

			spy.should.been.calledOnce
			spy.lastCall.args[0].should.to.have.deep.property 'column.id', 'id2' 
			spy.lastCall.args[0].should.have.deep.property 'column.data', null

	describe 'method getColumnById', ->
		beforeEach ->
			tab.columns =
				'id1': {name: 'one', type: 'char'}
				'id2': {name: 'second', type: 'varchar'}

		it 'should return null if id not passed', ->
			expect(tab.getColumnById()).to.be.null

		it 'return null if column with passed id not exist', ->
			expect(tab.getColumnById 'id3').to.be.null

		it 'return column with passed id if exists', ->
			expect(tab.getColumnById 'id2').to.deep.equal {
				name: 'second', type: 'varchar'
			}

	describe 'method getColumnByName', ->
		before ->
			tab.columns =
				'id1': {name: 'one', type: 'char'}
				'id2': {name: 'second', type: 'varchar'}
				'id3': {name: 'third', type: 'number'}
				'id4': {name: 'fourth', type: 'varchar'}

		it 'should return null if column with passed name not exist', ->
			expect(tab.getColumnByName('fifth')).to.be.null

		it 'return column with passed name if exists', ->
			expect(tab.getColumnByName 'third').to.deep.equal {
				name: 'third', type: 'number'
			}

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
			tab.setIndex 'id3', 'fk'

			tab.indexes.should.have.property('id3').that.is.an.array
			tab.indexes['id3'].should.eql ['fk']

		it 'should insert index into list of indexes if index isnt there', ->
			tab.indexes['id1'] = ['fk']

			tab.setIndex 'id1', 'pk'

			tab.indexes['id1'].should.eql ['fk','pk']

		it 'should not insert index to list of indexes if index is there', ->	
			tab.indexes['id0'] = ['pk', 'fk']

			tab.setIndex 'id0', 'pk'
			tab.setIndex 'id0', 'fk'

			tab.indexes['id0'].should.eql ['pk','fk']

		it 'should remove index if passed third parameter true', ->
			tab.indexes['id3'] = ['pk', 'fk', 'unq']

			tab.setIndex 'id3', 'fk', true

			tab.indexes['id3'].should.eql ['pk', 'unq']

	describe 'method getColumnsIdsByIndex', ->
		beforeEach ->
			tab.indexes = {}

		it 'should return array of ids that has passed index', ->
			tab.indexes = {
				'id1': ['unq', 'fk'], 'id2': ['pk'], 'id3': ['unq'], 'id4': ['fk']
			}

			expect(tab.getColumnsIdsByIndex('unq')).to.deep.equal ['id1', 'id3']

		it 'should return empty array if no column has passed index', ->
			tab.indexes = {
				'id1': ['unq'], 'id2': ['fk'], 'id3': ['unq', 'fk'] 
			}
			pks = tab.getColumnsIdsByIndex('pk')

			expect(pks).to.be.an.array
			expect(pks).to.be.empty

	describe 'method toJSON', ->
		before ->
			sinon.stub(tab, 'getColumnsIdsByIndex').returns []

		beforeEach ->
			tab.name = 'table1'
			tab.columns =
				'id1': {name: 'one', type: 'char'}
				'id2': {name: 'second', type: 'varchar'}
				'id3': {name: 'third', type: 'number'}
			
			tab.indexes = 'id1': ['unq', 'fk'], 'id2': ['pk'], 'id3': ['unq']
			tab.getColumnsIdsByIndex.reset()

		after ->
			tab.getColumnsIdsByIndex.restore()

		it 'should retunn JSON like representation of model', ->
			json = tab.toJSON()

			expect(json).to.have.property 'name', 'table1'
			expect(json).to.have.deep.property 'columns.id1.name', 'one'
			expect(json).to.have.deep.property 'columns.id2.name', 'second'
			expect(json).to.have.deep.property 'columns.id3.name', 'third'
			expect(json).to.have.deep.property('indexes.id1').that.deep.equal [
				'unq', 'fk'
			]
			expect(json).to.have.deep.property('indexes.id2').that.deep.equal ['pk']
			expect(json).to.have.deep.property('indexes.id3').that.deep.equal ['unq']

		it 'should filter foreign key columns', ->
			tab.getColumnsIdsByIndex.returns ['id1']

			json = tab.toJSON()
			expect(json.columns).to.be.an('object').and.have.keys ['id2', 'id3']

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
goog.require 'dm.dialogs.TableDialog'

global.DB = types: [] 

describe 'class TableDialog', ->
	tabd = null

	before ->
		tabd = dm.dialogs.TableDialog.getInstance()

	describe 'constructor', ->
		it 'should have private property columns that held columns changes', ->
			tabd.should.have.property 'columns_'
			tabd.should.have.deep.property 'columns_.removed', null
			tabd.should.have.deep.property 'columns_.added', null
			tabd.should.have.deep.property 'columns_.updated', null
			tabd.should.have.deep.property 'columns_.count', 0

	describe 'method show', ->
		fakeModel = null
		faketab = null
		gch = null
		listen = null
		svi = null
		sva = null

		before ->
			fakeModel = 
				getColumns: sinon.stub()
				getName: sinon.stub()
				getColumnsIdsByIndex: sinon.stub()
			faketab = getModel: sinon.stub().returns fakeModel
			gch = sinon.stub goog.dom, 'getChildren'
			listen = sinon.stub goog.events, 'listen'
			svi = sinon.stub tabd, 'setVisible'
			sva = sinon.stub tabd, 'setValues'
			sinon.stub tabd, 'setTitle'

		beforeEach ->
			fakeModel.getColumns.reset()
			fakeModel.getName.reset()
			faketab.getModel.reset()
			gch.reset()
			listen.reset()
			svi.reset()
			sva.reset()
			tabd.setTitle.reset()

		after ->
			gch.restore()
			listen.restore()
			svi.restore()
			sva.restore()
			tabd.setTitle.restore()

		it 'should only show/hide if table not passed', ->
			tabd.show true

			svi.should.been.calledOnce
			faketab.getModel.should.not.been.called

		it 'should set first `added` column to list', ->
			gch.returns []
			fakeModel.getColumns.returns length: 5
			tabd.show true, faketab

			tabd.columns_.added.should.deep.equal [5]
			tabd.columns_.count.should.deep.equal 5

		it 'should listen all rows except first and last for change', ->
			gch.returns ['column0', 'column1', 'column2', 'column3']

			tabd.show true, faketab

			listen.should.been.calledTwice
			listen.should.been.calledWith 'column1'
			listen.should.been.calledWith 'column2'

		it 'should set title of dialog with table name if exists', ->
			fakeModel.getName.returns 'tab1'

			tabd.show true, faketab

			tabd.setTitle.should.been.calledWithExactly 'Table "tab1"'

		it 'should set title of dialog with "unnamed" if name doesnt exist', ->
			fakeModel.getName.returns ''

			tabd.show true, faketab

			tabd.setTitle.should.been.calledWithExactly 'Table "unnamed"'

	describe 'method getColumnData', ->
		beforeEach ->
			tabd.colslist.innerHTML = '<div class="row" name="2">'+
			'<span><input type="text" class="name" value="bob"/></span>'+
			'<span><select class="type"><option>T1</option></select></span>'+
			'<span><input type="checkbox" class="primary" /></span>'+
			'<span><input type="checkbox" class="notnull" checked /></span>'+
			'<span><input type="checkbox" class="unique" checked /></span></div>'+
			'<div class="row" name="3">'+
			'<span><input type="text" class="name" value="bobek"/></span>'+
			'<span><select class="type"><option>T2</option></select></span>'+
			'<span><input type="checkbox" class="primary" checked/></span>'+
			'<span><input type="checkbox" class="notnull" /></span>'+
			'<span><input type="checkbox" class="unique" /></span></div>' 

		it 'should find column by index and returns its values', ->
			tabd.getColumnData(3).should.deep.equal {
				model: name:'bobek', type:'T2',	isNotNull:false
				isUnique:false,	isPk: true
			}

		it 'should throw error if passed id not exist', ->
			expect(-> tabd.getColumnData(7)).to.throw 'Column not exist'

	describe 'method addColumn', ->
		beforeEach ->
			tabd.columns_.count = 0
			tabd.columns_.added = []

		it 'should increment count of columns', ->
			tabd.columns_.count = 5
			
			tabd.addColumn()
			tabd.columns_.count.should.equal 6

		it 'should push index of new column to array of added', ->
			tabd.columns_.added = [4, 5]
			tabd.columns_.count = 6

			tabd.addColumn()
			tabd.columns_.added.should.deep.equal [4, 5, 7]

	describe 'method removeColumn', ->
		gabc = null
		ga = null
		rn = null

		before ->
			ga = getAttribute: sinon.stub()
			gabc = sinon.stub(goog.dom,'getAncestorByClass').returns ga
			rn = sinon.stub goog.dom, 'removeNode'

		beforeEach ->
			tabd.columns_.added = []
			tabd.columns_.removed = []
			ga.getAttribute.reset()

		after ->
			gabc.restore()
			rn.restore()

		it 'it should remove index from list of added if exists there', ->
			tabd.columns_.added = [3, 4, 5, 6]
			tabd.columns_.removed = [3, 2]
			ga.getAttribute.returns '4'

			tabd.removeColumn 'column'

			tabd.columns_.should.have.property('added').that.deep.equal [3, 5, 6]
			tabd.columns_.should.have.property('removed').that.deep.equal [3, 2]

		it 'should add index to list of removed if it not in list of added', ->
			tabd.columns_.added = [3, 4, 5, 6]
			tabd.columns_.removed = [3, 2]
			ga.getAttribute.returns '8'

			tabd.removeColumn 'column'

			tabd.columns_.should.have.property('added').that.deep.equal [3, 4, 5, 6]
			tabd.columns_.should.have.property('removed').that.deep.equal [3, 2, 8]

	describe 'method onSelect', ->
		fakeModel = null
		gn = null
		gcd = null
		okev = key: 'ok'

		before ->
			fakeModel = 
				setName: sinon.spy(), setColumn: sinon.stub()
				removeColumn: sinon.spy(), setIndex: sinon.spy()

			tabd.table_ = getModel: sinon.stub().returns fakeModel
			gn = sinon.stub tabd, 'getName'
			gcd = sinon.stub tabd, 'getColumnData'

		beforeEach ->
			tabd.columns_ = added: [], updated: [], removed: [], count: 0
			fakeModel.setName.reset()
			fakeModel.setColumn.reset()
			fakeModel.removeColumn.reset()
			fakeModel.setIndex.reset()
			gn.reset()

		after ->
			gn.restore()
			gcd.restore()

		it 'should return true if pressed button isnt `ok`', ->
			tabd.onSelect(key: 'cancel').should.be.true
			tabd.onSelect(key: 'close').should.be.true

		it 'should always pass name of table from form to model', ->
			gn.returns 'tabname'

			tabd.onSelect okev

			fakeModel.setName.should.been.calledWith 'tabname'

		it 'should set all columns in list for update to model', ->
			gcd.withArgs(1).returns model: 'model1', isUnique: true, isPk: false
			gcd.withArgs(5).returns model: 'model5', isUnique: false, isPk: true
			gcd.withArgs(3).returns model: 'model3', isUnique: true, isPk: false
			tabd.columns_.updated = [1, 5, 3]

			tabd.onSelect okev

			fakeModel.setColumn.should.been.calledThrice
			fakeModel.setColumn.should.been.calledWithExactly 'model1', 1
			fakeModel.setColumn.should.been.calledWithExactly 'model5', 5
			fakeModel.setColumn.should.been.calledWithExactly 'model3', 3

		it 'should add or delete primary and unique indexes for all columns by its flags', ->
			tabd.columns_.updated = [1, 5, 3]
			unqStr = dm.model.Table.index.UNIQUE
			pkStr = dm.model.Table.index.PK

			tabd.onSelect okev

			fakeModel.setIndex.callCount.should.equal 6
			fakeModel.setIndex.should.been.calledWithExactly 1, unqStr, false
			fakeModel.setIndex.should.been.calledWithExactly 5, unqStr, true
			fakeModel.setIndex.should.been.calledWithExactly 3, unqStr, false
			fakeModel.setIndex.should.been.calledWithExactly 1, pkStr, true
			fakeModel.setIndex.should.been.calledWithExactly 5, pkStr, false
			fakeModel.setIndex.should.been.calledWithExactly 3, pkStr, true

		it 'should remove all columns in list from model', ->
			tabd.columns_.removed = [2, 8]
			
			tabd.onSelect okev

			fakeModel.removeColumn.should.been.calledTwice
			fakeModel.removeColumn.should.been.calledWithExactly 2
			fakeModel.removeColumn.should.been.calledWithExactly 8

		it 'should set all columns in list for add to model if column has name', ->
			tabd.columns_.added = [5, 6, 7, 8]
			gcd.withArgs(5).returns model: { name: 'five' }, isUnique: false
			gcd.withArgs(6).returns model: { name: '' }, isUnique: false
			gcd.withArgs(7).returns model: { name: 'seven' }, isUnique: true
			gcd.withArgs(8).returns model: { name: undefined }, isUnique: false

			tabd.onSelect okev

			fakeModel.setColumn.should.been.calledTwice
			fakeModel.setColumn.should.been.calledWithExactly name: 'five'
			fakeModel.setColumn.should.been.calledWithExactly name: 'seven'

		it 'should add unique or primary index for new columns that had them', ->
			tabd.columns_.added = [6, 7, 8, 9]
			unqStr = dm.model.Table.index.UNIQUE
			pkStr = dm.model.Table.index.PK

			gcd.withArgs(6).returns model: {name: 'one'}, isUnique: false, isPk: true
			gcd.withArgs(7).returns model: {name: 'two'}, isUnique: true, isPk: false
			gcd.withArgs(8).returns model: {name: 'thr'}, isUnique: true, isPk: false
			gcd.withArgs(9).returns model: {name: null}, isUnique: true, isPk: true

			fakeModel.setColumn.withArgs({ name: 'one' }).returns 6
			fakeModel.setColumn.withArgs({ name: 'two' }).returns 7
			fakeModel.setColumn.withArgs({ name: 'thr' }).returns 8

			tabd.onSelect okev

			fakeModel.setIndex.should.been.calledThrice
			fakeModel.setIndex.should.been.calledWithExactly 6, pkStr
			fakeModel.setIndex.should.been.calledWithExactly 7, unqStr
			fakeModel.setIndex.should.been.calledWithExactly 8, unqStr		
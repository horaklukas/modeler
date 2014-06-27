goog.require 'dm.model.ModelManager'

describe 'class model.ModelManager', ->
	before ->
		@mngr = new dm.model.ModelManager('canvas')
		@tabModel = 
			setIndex: sinon.spy()
			setColumn: sinon.spy()
			getColumnById: sinon.stub()

		@relationModel = 
			getColumnsMapping: sinon.stub()
			setColumnsMapping: sinon.spy()
			getOppositeMappingId: sinon.stub()
			setCardinalityAndModality: sinon.stub()
			isIdentifying: sinon.stub()

	describe 'method createActualFromLoaded', ->
		before ->

			sinon.stub @mngr, 'bakupOldCreateNewActual'
			sinon.stub @mngr, 'columnCoercion', (value) -> value
			sinon.stub @mngr, 'addTable'
			sinon.stub @mngr, 'addRelation'
			sinon.stub(dm.model, 'Table').returns @tabModel
			sinon.stub(dm.model, 'Relation').returns @relationModel

		beforeEach ->
			dm.model.Table.reset()
			dm.model.Relation.reset()

		after ->
			@mngr.bakupOldCreateNewActual.restore()
			@mngr.columnCoercion.restore()
			@mngr.addTable.restore()
			@mngr.addRelation.restore()
			dm.model.Table.restore()
			dm.model.Relation.restore()

		describe 'tables recreate', ->
			it 'should create object from columns and pass to model', ->
				tablesdata = [{
						'model':
							'name':'parent'
							'columns':
								':9':'name':'parent_id','type':'serial'
								':a':'name':'sloupec','type':'smallint'
						'pos': 'x': 0, 'y': 0
					}]

				@mngr.createActualFromLoaded 'nm', tablesdata, []

				dm.model.Table.should.been.calledOnce.and.calledWithNew
				dm.model.Table.lastCall.args[1].should.deep.equal {
					':9':'name':'parent_id','type':'serial'
					':a':'name':'sloupec','type':'smallint'
				}

		describe 'relations recreate', ->
			before ->
				@relationsdata = [{	
					'type': true,
					'mapping': [{'parent':':9', 'child':':g'}],
					'tables': {'parent':'parenttab','child':'childtab'}
					'name': 'rel1'
				}]

				@tablesdata = [{
						'model':
							'name':'parenttab'
							'columns':
								':9':'name':'parent_id','type':'serial'
								':a':'name':'sloupec','type':'smallint'
						'pos': 'x': 10, 'y': 20
					},{	
						'model':
							'name':'childtab'
							'columns':
								':g':'name':'child_fk','type':'number'
								':s':'name':'sloupec','type':'character varying'
						'pos': 'x': 0, 'y': 0
				}]

				@childTable =
					setColumn: sinon.stub()

				@mngr.actualModel = 
					getTableIdByName: sinon.stub()
					getTableById: sinon.stub().withArgs('ch0').returns @childTable

				@mngr.actualModel.getTableIdByName.withArgs('parenttab').returns 'p0'
				@mngr.actualModel.getTableIdByName.withArgs('childtab').returns 'ch0'
				@relationModel.getOppositeMappingId.withArgs(':9').returns ':c'

			beforeEach ->
				@mngr.actualModel.getTableIdByName.reset()
				@childTable.setColumn.reset()

			it 'should add relation with type,tables names and relation name', ->
				@mngr.createActualFromLoaded 'nm', @tablesdata, @relationsdata

				dm.model.Relation.should.been.calledOnce.and.calledWithNew
				dm.model.Relation.should.been.calledWithExactly true, 'p0', 'ch0', 'rel1'


			it 'should rename fk columns on child table to correct name', ->
				@mngr.createActualFromLoaded 'nm', @tablesdata, @relationsdata

				@childTable.setColumn.should.been.calledOnce
				@childTable.setColumn.should.been.calledWithExactly(
					{'name':'child_fk','type':'number'}, ':c'
				)

	describe 'method onParentColumnChange', ->
		before ->
			@fakeRel = 
				getModel: sinon.stub().returns @relationModel
				recountPosition: sinon.spy()
				addForeignKeyColumn: sinon.stub()

			@fakeTab =
			 	getModel: sinon.stub().returns @tabModel
			 	getElement: sinon.stub()

			@fakeEv = 
				type: ''
				column: null

			sinon.stub @mngr, 'deleteRelation'

		beforeEach ->
			@mngr.deleteRelation.reset()

		after ->
			@mngr.deleteRelation.restore()

		describe 'column-delete', ->
			before ->
				@fakeEv.type = 'column-delete'

		describe 'column-add', ->
			before ->
				@fakeEv.type = 'column-add'
				@fakeEv.column = id: 'id2'

			beforeEach ->
				@relationModel.getColumnsMapping.returns []
				@relationModel.setColumnsMapping.reset()
				@fakeRel.addForeignKeyColumn.reset()

			it 'should not add fk column if added column has no indexes', ->
				@fakeEv.column.data = {}

				@mngr.onParentColumnChange @fakeRel, @fakeTab, @fakeTab, @fakeEv

				@fakeRel.addForeignKeyColumn.should.not.been.called

			it 'should not add fk column if added column has not PK index', ->
				@fakeEv.column.data = indexes: [dm.model.Table.index.FK]

				@mngr.onParentColumnChange @fakeRel, @fakeTab, @fakeTab, @fakeEv

				@fakeRel.addForeignKeyColumn.should.not.been.called

			it 'should not add fk column if added column has PK and FK index', ->
				@fakeEv.column.data = indexes: [
					dm.model.Table.index.PK, dm.model.Table.index.FK
				]

				@mngr.onParentColumnChange @fakeRel, @fakeTab, @fakeTab, @fakeEv

				@fakeRel.addForeignKeyColumn.should.not.been.called

			it 'should add foreign key if passed column has PK index', ->
				@relationModel.isIdentifying.returns true
				@fakeEv.column.data = 
					indexes: [dm.model.Table.index.PK]

				@mngr.onParentColumnChange @fakeRel, @fakeTab, @fakeTab, @fakeEv

				@fakeRel.addForeignKeyColumn.should.been.calledOnce
				@fakeRel.addForeignKeyColumn.should.been.calledWithExactly(
					@fakeEv.column.data, @tabModel, true
				)

			it 'should add new columns mapping for created columns', ->
				@fakeEv.column.data = 
					indexes: [dm.model.Table.index.PK]
				@fakeRel.addForeignKeyColumn.returns 'idch1'

				@mngr.onParentColumnChange @fakeRel, @fakeTab, @fakeTab, @fakeEv

				@relationModel.setColumnsMapping.should.been.calledOnce
				@relationModel.setColumnsMapping.should.been.calledWithExactly(
					[{parent: 'id2', child: 'idch1'}]
				)

		describe 'column-change', ->
			before ->
				@fakeEv.type = 'column-change'
				@fakeEv.column = id: 'cid'

			it 'should do nothing if column isnt in mappings', ->
				@relationModel.getOppositeMappingId.returns null

				@mngr.onParentColumnChange @fakeRel, @fakeTab, @fakeTab, @fakeEv

				@tabModel.getColumnById.should.not.been.called

			it 'should should change length and type of child column by parent', ->
				column = length: 10, type: 'char'
				@fakeEv.column.data = {type: 'integer', length: null}
				@relationModel.getOppositeMappingId.withArgs('cid').returns 'chid'
				@tabModel.getColumnById.withArgs('chid').returns column
				 
				@mngr.onParentColumnChange @fakeRel, @fakeTab, @fakeTab, @fakeEv

				expect(column).to.deep.equal {length: null, type: 'integer'}


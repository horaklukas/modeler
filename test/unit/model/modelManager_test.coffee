goog.require 'dm.model.ModelManager'

describe 'class model.ModelManager', ->
	before ->
		@mngr = new dm.model.ModelManager('canvas')

	describe 'method createActualFromLoaded', ->
		before ->
			@tabModel = setIndex: sinon.spy()
			@relationModel = getOppositeMappingId: sinon.stub()
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

			it 'should add relation with type and tables names', ->
				@mngr.createActualFromLoaded 'nm', @tablesdata, @relationsdata

				dm.model.Relation.should.been.calledOnce.and.calledWithNew
				dm.model.Relation.should.been.calledWithExactly true, 'p0', 'ch0'


			it 'should rename fk columns on child table to correct name', ->
				@mngr.createActualFromLoaded 'nm', @tablesdata, @relationsdata

				@childTable.setColumn.should.been.calledOnce
				@childTable.setColumn.should.been.calledWithExactly(
					{'name':'child_fk','type':'number'}, ':c'
				)
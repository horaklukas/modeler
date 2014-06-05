goog.require 'dm.model.ModelManager'

describe 'class model.ModelManager', ->
	before ->
		@mngr = new dm.model.ModelManager('canvas')

	describe 'method createActualFromLoaded', ->
		before ->
			@tabModel = setIndex: sinon.spy()
			sinon.stub @mngr, 'bakupOldCreateNewActual'
			sinon.stub @mngr, 'columnCoercion', (value) -> value
			sinon.stub @mngr, 'addTable'
			sinon.stub(dm.model, 'Table').returns @tabModel

		beforeEach ->
			dm.model.Table.reset()

		after ->
			@mngr.bakupOldCreateNewActual.restore()
			@mngr.columnCoercion.restore()
			dm.model.Table.restore()

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

			it 'should remove property indexes when column have it', ->
				tablesdata = [{
						'model':
							'name':'parent'
							'columns':
								':9':'name':'parent_id','type':'serial', 'indexes': ['PK']
						'pos': 'x': 0, 'y': 0
					}]

				
				@mngr.createActualFromLoaded 'nm', tablesdata, []

				dm.model.Table.should.been.calledOnce.and.calledWithNew
				dm.model.Table.lastCall.args[1].should.have.property ':9'
				dm.model.Table.lastCall.args[1][':9'].should.have.keys ['name', 'type']
				dm.model.Table.lastCall.args[1][':9'].should.not.have.keys ['indexes']

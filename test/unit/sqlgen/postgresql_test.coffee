goog.require 'dm.sqlgen.Postgresql'

describe 'class PostgreSQL generator', ->
	before ->
		# temporary mock
		global.React = renderComponent: ->

		sinon.stub dm.ui, 'SqlCodeDialog'
		@gen = dm.sqlgen.Postgresql.getInstance()		

	after ->
		dm.ui.SqlCodeDialog.restore()

	describe.skip 'method createColumn', ->
		before ->
			console.log @gen.__super__, @gen
			@ccsuper = sinon.stub @gen.__super__, 'createColumn'

		after ->

		it 'change type serial to int if column is foreign key', ->
goog.provide 'dm.sqlgen.Postgresql'

goog.require 'dm.sqlgen.Sql'
goog.require 'dm.model.Table'
goog.require 'goog.array'

class dm.sqlgen.Postgresql extends dm.sqlgen.Sql
	###*
  * @override
	###
	createColumn: (column) ->
		if column.indexes? and
		goog.array.contains(column.indexes, dm.model.Table.index.FK) and
		/serial/.test column.type
			column.type = 'integer'

		super column

goog.addSingletonGetter dm.sqlgen.Postgresql
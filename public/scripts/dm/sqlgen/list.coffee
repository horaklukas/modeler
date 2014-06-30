goog.provide 'dm.sqlgen.list'

goog.require 'dm.sqlgen.Sql'
goog.require 'dm.sqlgen.Postgresql'

dm.sqlgen.list =
	'sql': dm.sqlgen.Sql.getInstance()
	'postgresql': dm.sqlgen.Postgresql.getInstance()
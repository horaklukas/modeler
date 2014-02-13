###*
* @fileoverview Base class for generating SQL scripts from database model
*  can be extend by specific sql implementations which may override any methods
*  if their syntax is different than common SQL-92
###

goog.provide 'dm.sqlgen.Sql92'

goog.require 'dm.model.Table.index'
goog.require 'goog.array'
goog.require 'goog.ui.Dialog'
goog.require 'goog.ui.Dialog.ButtonSet'

class dm.sqlgen.Sql92
	###*
  * @param {Object} options
	###
	constructor: (@options) ->
		###*
    * @type {goog.ui.Dialog}
		###
		@dialog = new goog.ui.Dialog()
		@dialog.setButtonSet goog.ui.Dialog.ButtonSet.OK

	generate: (model) ->
		sql = ''
		parentTables = {}
		tables = @getTablesByName_ model.tables

		for tableName, table of tables
			for rel in model.relations when rel.tables.child is tableName
				columnsMapping = rel.getColumnsMapping()
				parentTableColumns = tables[rel.tables.parent].getColumns()

				for keyMap in columnsMapping
					parentTables[keyMap.child] = {
						table: rel.tables.parent
						column: parentTableColumns[keyMap.parent].name
					}
			
			sql += @createTable table, parentTables

		@showDialog sql

	###*
  * @param {dm.model.Table} table
  * @param {Object.<number, string>=} parentTabs Tables that are parent
  *  tables of passed table
  * @return {string} generated sql code that create table
	###
	createTable: (table, parentTabs = {}) ->
		columns = table.getColumns()
		mapName = (id) -> columns[id].name

		pks = goog.array.map table.getColumnsIdsByIndex(dm.model.Table.index.PK), mapName 
		uniques = goog.array.map table.getColumnsIdsByIndex(dm.model.Table.index.UNIQUE), mapName
		fks = table.getColumnsIdsByIndex(dm.model.Table.index.FK)

		colsSql = goog.array.map columns, (column) => "\t#{@createColumn column}"

		if uniques.length then colsSql.push "\tUNIQUE (#{uniques.join ', '})"
		if pks.length then colsSql.push "\tPRIMARY KEY (#{pks.join ', '})"
		if fks.length then for fk in fks
			colsSql.push "\tFOREIGN KEY (#{columns[fk].name}) REFERENCES " +
				"#{parentTabs[fk].table} (#{parentTabs[fk].column})"

		"CREATE TABLE #{table.getName()} (\n #{colsSql.join ',\n'} \n);\n\n"

	###*
  * @param {dm.mode.TableColumn} column
  * @return {string} piece of sql that defines table column
	###
	createColumn: (column) ->
		notNull = if column.isNotNull then ' NOT NULL' else ''
		
		"#{column.name} #{column.type}#{notNull}"

	###*
  * Maps tables by its names
  *
  * @param {Array.<dm.model.Table>} tables
  * @return {Object.<string, dm.model.Table>}
  * @private
	###
	getTablesByName_: (tables) ->
		mappedTables = {}
		
		mappedTables[table.getName()] = table for table in tables

		mappedTables

	###*
  * @param {string} sql
	###
	showDialog: (sql) -> 
		@dialog.setTitle 'SQL'
		@dialog.setContent "<textarea cols='100' rows='20'>#{sql}</textarea>"
		@dialog.setVisible true
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
		tablesByName = @getTablesByName_ model.tables

		for table in model.tables
			sql += @createTable table 

		for rel in model.relations
			{parent, child} = rel.tables
			parentColumns = tablesByName[parent].getColumns()
			childColumns = tablesByName[child].getColumns()
			
			sql += "/* Relation between tables #{parent} and #{child} */\n"
			sql += @createRelationConstraint rel, childColumns, parentColumns

		@showDialog sql

	###*
  * Gets name of object (table, relation, etc.) and returns its shortcut
  * useful at eg. names of constraints
  *
  * @param {string} name
  * @return {string}
	###
	getNameShortcut: (name) ->
		name.toLowerCase().substr(0, 3)

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

		colsSql = goog.array.map columns, (column) => "\t#{@createColumn column}"

		if uniques.length then colsSql.push "\tUNIQUE (#{uniques.join ', '})"
		if pks.length then colsSql.push "\tPRIMARY KEY (#{pks.join ', '})"

		"CREATE TABLE #{table.getName()} (\n #{colsSql.join ',\n'} \n);\n\n"

	###*
  * Generates sql for creating foreign key constraints belongs to relation
  * 
  * @param {dm.model.Relation} rel Model of related relation
  * @param {Array.<dm.model.TableColumn>} childColumns List of columns of child
  *  table related with the relation
  * @param {Array.<dm.model.TableColumn>} parentColumns List of columns of 
  *  parent table related with the relation
  * @return {string} generated sql
	###
	createRelationConstraint: (rel, childColumns, parentColumns) ->
		{parent, child} = rel.tables
		columnsMapping = rel.getColumnsMapping()

		childColumnsNames = []
		parentColumnsNames = []

		# name of constraint, unique in scope of table
		name = "constr_#{@getNameShortcut child}_#{@getNameShortcut parent}_fk"

		for map in columnsMapping
			childColumnsNames.push childColumns[map.child].name
			parentColumnsNames.push parentColumns[map.parent].name

		"ALTER TABLE #{child} ADD CONSTRAINT #{name} FOREIGN KEY " +
			"(#{childColumnsNames.join(', ')}) REFERENCES " +
			"#{parent} (#{parentColumnsNames.join(', ')});\n\n"

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
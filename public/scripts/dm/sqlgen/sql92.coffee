###*
* @fileoverview Base class for generating SQL scripts from database model
*  can be extend by specific sql implementations which may override any methods
*  if their syntax is different than common SQL-92
###

goog.provide 'dm.sqlgen.Sql92'

goog.require 'dm.model.Table.index'
goog.require 'goog.array'

class dm.sqlgen.Sql92
	###*
  * @param {Object} options
	###
	constructor: (@options) ->

	generate: (model) ->
		sql = ''

		sql += @createTable table for table in model.tables

		console.log sql

	###*
  * @param {dm.model.Table} table
  * @return {string} generated sql code that create table
	###
	createTable: (table) ->
		columns = table.getColumns()
		mapName = (id) -> columns[id].name

		pks = goog.array.map table.getColumnsIdsByIndex(dm.model.Table.index.PK), mapName 
		uniques = goog.array.map table.getColumnsIdsByIndex(dm.model.Table.index.UNIQUE), mapName

		colsSql = goog.array.map columns, (column) => "\t#{@createColumn column}"

		if uniques.length then colsSql.push "\tUNIQUE (#{uniques.join ', '})"
		if pks.length then colsSql.push "\tPRIMARY KEY (#{pks.join ', '})"

		"CREATE TABLE #{table.getName()} (\n #{colsSql.join ',\n'} \n);\n\n"

	###*
  * @param {dm.mode.TableColumn} column
  * @return {string} piece of sql that defines table column
	###
	createColumn: (column) ->
		notNull = if column.isNotNull then ' NOT NULL' else ''
		
		"#{column.name} #{column.type}#{notNull}"


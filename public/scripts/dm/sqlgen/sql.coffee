###*
* @fileoverview Base class for generating SQL scripts from database model
*  can be extend by specific sql implementations which may override any methods
*  if their syntax is different than common SQL-92
###

goog.provide 'dm.sqlgen.Sql'

goog.require 'dm.model.Table.index'
goog.require 'goog.array'
goog.require 'dm.ui.SqlCodeDialog'

class dm.sqlgen.Sql
	###*
  * @param {Object} options
	###
	constructor: (@options) ->
		###*
    * @type {goog.ui.Dialog}
		###
		@dialog = React.renderComponent(
			dm.ui.SqlCodeDialog()
			goog.dom.getElement 'sqlCodeDialog'
		)

		###*
		* List of names of already created foreign key constraints, used to ensure
		* uniqueness of constraint name
		*
		* @type {Array.<string>}
		###
		@relConstraintNames = []

	generate: (model) ->
		sql = ''
		@relConstraintNames = []

		for name, table of model.tables
			sql += @createTable table 

		for id, rel of model.relations
			parentModel = model.tables[rel.tables.parent]
			childModel = model.tables[rel.tables.child]
			
			sql += "/* Relation between tables #{parentModel.getName()} " +
				"and #{childModel.getName()} */\n"
			sql += @createRelationConstraint rel, parentModel, childModel

		@dialog.show sql

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

		colsSql = []
		goog.object.forEach columns, (column) => 
			colsSql.push "\t#{@createColumn column}"

		if uniques.length then colsSql.push "\tUNIQUE (#{uniques.join ', '})"
		if pks.length then colsSql.push "\tPRIMARY KEY (#{pks.join ', '})"

		"CREATE TABLE #{table.getName()} (\n #{colsSql.join ',\n'} \n);\n\n"

	###*
  * Generates sql for creating foreign key constraints belongs to relation
  * 
  * @param {dm.model.Relation} rel Model of related relation
  * @param {dm.model.Table} childModel 
  * @param {dm.model.Table} parentModel
  * @return {string} generated sql
	###
	createRelationConstraint: (rel, parentModel, childModel) ->
		parent = parentModel.getName()
		child = childModel.getName()
		parentColumns = parentModel.getColumns()
		childColumns = childModel.getColumns()
		columnsMapping = rel.getColumnsMapping()

		childColumnsNames = []
		parentColumnsNames = []

		# name of constraint, unique in scope of table
		name = @getUniqueConstraintName child, parent
		
		@relConstraintNames.push name
		
		for map in columnsMapping
			childColumnsNames.push childColumns[map['child']].name
			parentColumnsNames.push parentColumns[map['parent']].name

		"ALTER TABLE #{child} ADD CONSTRAINT #{name} FOREIGN KEY " +
			"(#{childColumnsNames.join(', ')}) REFERENCES " +
			"#{parent} (#{parentColumnsNames.join(', ')});\n\n"

	###*
	* Returns unique name of foreign key constraint
	*
  * @param {string} child Name of child table
  * @param {string} parent Name of parent table
	###
	getUniqueConstraintName: (child, parent) ->
		childShortcut = child.toLowerCase().substr(0, 3)
		parentShortcut = parent.toLowerCase().substr(0, 3)

		id = -1
		pos = 0
		name = "constr_#{childShortcut}_#{parentShortcut}_fk"

		while pos > -1
			id++
			pos = goog.array.indexOf @relConstraintNames, name + id 
		
		name + id

	###*
  * @param {dm.mode.TableColumn} column
  * @return {string} piece of sql that defines table column
	###
	createColumn: (column) ->
		data = ["`#{column.name}`", column.type.toUpperCase()]
		data.push 'NOT NULL' if column.isNotNull
		data[1] += "(#{column.length})" if column.length
		
		data.join ' '

goog.addSingletonGetter dm.sqlgen.Sql
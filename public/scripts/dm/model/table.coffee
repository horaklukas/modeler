goog.provide 'dm.model.Table'
goog.provide 'dm.model.Table.index'

goog.require 'goog.events.EventTarget'
goog.require 'goog.events.Event'
goog.require 'goog.array'
goog.require 'goog.object'
goog.require 'goog.ui.IdGenerator'

###*
* @typedef {{name:string, type:string, isNotNull:boolean}}
###
dm.model.TableColumn

class dm.model.Table extends goog.events.EventTarget
	###*
  * @enum {string}
	###
	@index:
		FK: 'FK'
		PK: 'PK'
		UNIQUE: 'UNQ'

	###*
	* @param {string=} name
	* @param {Array.<dm.model.TableColumn>=} columns
	* @constructor
	* @extends {goog.events.EventTarget}
	###
	constructor: (name = '', columns = []) ->
		super @

		###* 
    * table's list of related relations
    * @type {string}
    ###
		@name = name

		###*
    * @type {Object.<string, dm.model.TableColumn>}
		###
		@columns = columns

		###*
	  * @type {Object.<number, type}
		###
		@indexes = {}

	###*
  * @param {string} name
	###
	setName: (name = '') ->
		@name = name
		@dispatchEvent 'name-change'

	###*
  * @return {string}
	###
	getName: ->
		@name

	###*
	* Adds new columns or updates existing
	* @param {Array.<(Object,<string,*>|dm.model.TableColumnModel)>} columns List of
	*  table columns at keys based object
	###
	###
	setColumns: (columns) ->
		@setColumn column for column in columns 
	###

	###*
	* Add new or update existing column 
	* 
  * @param {dm.model.TableColumn} column
	* @param {number=} id
	* @return {number} id of new or updated column
	###
	setColumn: (column, id) ->
		# before add (or update) column check if its name is unique and add suffix
		# in case that not
		column.name = @getUniqueColumnName column.name

		if id?
			@columns[id] = column
			newColumn = false
		else
			# generate unique id for a new column
			id = goog.ui.IdGenerator.getInstance().getNextUniqueId()
			@columns[id] = column
			newColumn = true

		# add additional information about column's indexes
		if @indexes[id] then column.indexes = @indexes[id]

		@dispatchEvent new dm.model.Table.ColumnsChange column, id, newColumn
		
		return id

	###*
  * @param {string} name Name of column to check if it is unique
	* @param {number=} id Optional id of existing column which is updating and
	*  its name should been unified
  * @return {string}
	###
	getUniqueColumnName: (name, id) ->
		columnName = name
		numberSuffix = 0

		###
		columnByName = @getColumnByName column.name
		if columnByName? and columnByName isnt @columns[id]
			column.name += '_0'
		###

		while (column = @getColumnByName(columnName))?
			# if found column with same name is column itself dont add suffix
			if id? and column is @columns[id] then break

			columnName = "#{name}_#{numberSuffix++}"

		columnName

	###*
  * @return {Object.<string, dm.model.TableColumn>} table columns
	###
	getColumns: ->
		goog.object.clone @columns
	
	###*
  * @param {!string} id Id of column to remove
	###
	removeColumn: (id) ->
		goog.object.remove @columns, id
		goog.object.remove @indexes, id

		@dispatchEvent new dm.model.Table.ColumnsChange null, id

	###*
  * @param {string=} id
  * @return {?dm.model.TableColumn}
	###
	getColumnById: (id) ->
		unless id? then null
		@columns[id] ? null

	###*
	* @param {string} name
  * @return {(dm.model.TableColumn|null)}
	###
	getColumnByName: (name) ->
		return col for id, col of @columns when col.name is name
		return null

	###*
  * @param {string} id Related column id
  * @param {dm.model.Table.index} type
  * @param {boolean} del If true then column will be deleted, else upserted
	###
	setIndex: (id, type, del) ->
		if del is true 
			if @indexes[id]? then goog.array.remove @indexes[id], type
		else
			@indexes[id] ?= []
			goog.array.insert @indexes[id], type

		column = @getColumnById id
		
		# add additional information about column's indexes
		if column?
			column.indexes = @indexes[id]
			@dispatchEvent new dm.model.Table.ColumnsChange column, id

	###*
  * @param {dm.model.Table.index} index Type of index
  * @return {Array.<number>} indexes of columns that have passed index
	###
	getColumnsIdsByIndex: (index) ->
		id for id, idx of @indexes when goog.array.contains(idx, index)

	###*
  * @return {Object} table model at JSON representation
	###
	toJSON: ->
		fks = @getColumnsIdsByIndex dm.model.Table.index.FK
		# foreign key columns are created by relation
		columns =  goog.object.filter @columns, (column, idx) -> idx not in fks

		'name': @name
		'columns': columns
		'indexes': @indexes

class dm.model.Table.ColumnsChange extends goog.events.Event
	###*
  * @param {?dm.model.TableColumn} column
  * @param {number=} id
  * @param {boolean} newColumn
	###
	constructor: (column, id, newColumn = false) ->
		if newColumn
			eventName = 'column-add'
		else
			eventName = if column? then 'column-change' else 'column-delete' 

		super eventName

		@column = data: column,	id: id
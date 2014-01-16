goog.provide 'dm.model.Table'
goog.provide 'dm.model.Table.index'

goog.require 'goog.events.EventTarget'
goog.require 'goog.events.Event'
goog.require 'goog.array'

###*
* @typedef {{name:string, type:string, isPk: boolean, isNotNull:boolean, isUnique:boolean}}
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
		@name_ = name

		###*
    * @type {Array.<dm.model.TableColumn>}
		###
		@columns_ = columns

		###*
	  * @type {Object.<number, type}
		###
		@indexes = {}

	###*
  * @param {string} name
	###
	setName: (name = '') ->
		@name_ = name
		@dispatchEvent 'name-change'

	###*
  * @return {string}
	###
	getName: ->
		@name_

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
	* @param {number=} idx
	* @return {number} id of new or updated column
	###
	setColumn: (column, idx) ->
		if idx? then @columns_[idx] = column
		else @columns_.push column

		if @indexes[column.name] then column.indexes = @indexes[column.name]

		@dispatchEvent new dm.model.Table.ColumnsChange column, idx
		
		idx ? @columns_.length - 1

	###*
  * @return {Array.<dm.model.TableColumn>} table columns
	###
	getColumns: ->
		@columns_
	
	###*
  * @param {!number} idx
	###
	removeColumn: (idx) ->
		goog.array.removeAt @columns_, idx

		@dispatchEvent new dm.model.Table.ColumnsChange null, idx

	###*
  * @param {string=} idx
  * @return {?dm.model.TableColumn}
	###
	getColumnById: (idx) ->
		unless idx? then null
		@columns_[idx] ? null

	###*
	* @param {string} name
  * @return {(dm.model.TableColumn|null)}
	###
	getColumnByName: (name) ->
		return col for col in @columns_ when col.name is name
		return null

	###*
  * @param {number} id
  * @param {dm.model.Table.index} type
  * @param {boolean} del If true then column will be deleted, else upserted
	###
	setIndex: (id, type, del) ->
		if del is true 
			if @indexes[id]? then goog.array.remove @indexes[id], type
		else
			@indexes[id] ?= []
			goog.array.insert @indexes[id] , type

		column = @getColumnById id
				
		if column?
			column.indexes = @indexes[id]
			@dispatchEvent new dm.model.Table.ColumnsChange column, id

	###*
  * @param {dm.model.Table.index} index Type of index
  * @param {Array.<number>} indexes of columns that have passed index
	###
	getColumnsIdsByIndex: (index) ->
		id for id, colIdxs of @indexes when goog.array.contains(colIdxs, index)

class dm.model.Table.ColumnsChange extends goog.events.Event
	###*
  * @param {?dm.model.TableColumn} column
  * @param {number=} idx
	###
	constructor: (column, idx) ->
		if idx?
			eventName = if column? then 'column-change' else 'column-delete' 
		else
			eventName = 'column-add'

		super eventName

		@column = data: column,	index: idx
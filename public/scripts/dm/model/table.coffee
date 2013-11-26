goog.provide 'dm.model.Table'

goog.require 'goog.events.EventTarget'
goog.require 'goog.events.Event'
goog.require 'goog.array'

###*
* @typedef {{name:string, type:string, isPk: boolean, isNotNull:boolean, isUnique:boolean}}
###
dm.model.TableColumn

class dm.model.Table extends goog.events.EventTarget
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
  * @param {dm.model.TableColumn} column
	* @param {number=} idx
	###
	setColumn: (column, idx) ->
		if idx? then @columns_[idx] = column
		else @columns_.push column

		@dispatchEvent new dm.model.Table.ColumnsChange column, idx
		
		#if isFk then @fkeys.push newColumn.name

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
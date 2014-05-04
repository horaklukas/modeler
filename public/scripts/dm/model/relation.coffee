goog.provide 'dm.model.Relation'

goog.require 'goog.events.EventTarget'

class dm.model.Relation extends goog.events.EventTarget
	###*
  * @param {boolean} identify True if relation is identifying
  * @param {dm.model.Table} parent Relation parent table model
  * @param {dm.model.Table} child Relation child table model
  * @constructor
  * @extends {goog.events.EventTarget}
	###
	constructor: (identify, parent, child) ->
		super()
		#@setRelatedTables startTab, endTab
		
		###*
    * @type {boolean}
		###
		@identifying_ = identify

		###*
		* List of parent column id -> child column id mapping
    * @type {Array.<Object.<string, number>>} 
		###
		@keyColumnsMapping_ = []

		###*
	  * @type {Object.<dm.model.Table, dm.model.Table>}
		###
		@tables = 
			parent: null
			child: null
		
	###*
	* @param {boolean} identify True if relation is identyfing
	###
	setType: (identify) ->
		@identifying_ = identify

		@dispatchEvent 'type-change'
		
	###*
	* @return {boolean}
	###
	isIdentifying: ->
		@identifying_

	###*
  * Saves list of ids of child table columns that are foreign keys and 
  *  corresponding parent table columns that are primary keys 
  * @param {Array.<Object.<string,number>>} ids
	###
	setColumnsMapping: (ids) ->
		@keyColumnsMapping_ = ids

	###
	* @return {Array.<Object.<string,number>>}
	###
	getColumnsMapping: ->
		@keyColumnsMapping_
		
	###*
  * @param {?string} parent Name of parent table
  * @param {?string=} child Name of child table
	###
	setRelatedTables: (parent, child) =>
		if parent? then @tables.parent = parent
		if child? then @tables.child = child

	###
	 * @return {Object} table model at JSON representation
	###
	toJSON: ->
		'type': @identifying_
		'mapping': @keyColumnsMapping_
		'tables': @tables
goog.provide 'dm.model.Relation'

goog.require 'goog.events.EventTarget'

class dm.model.Relation extends goog.events.EventTarget
	###*
  * @param {boolean} identify True if relation is identifying
  * @param {string} parent Relation parent table id
  * @param {string} child Relation child table id
  * @param {string=} name Relation name
  * @constructor
  * @extends {goog.events.EventTarget}
	###
	constructor: (identify, parent, child, name) ->
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

		@name_ = name ? 'new relation'

		###*
		* Id of parent and child table
	  * @type {Object.<string, string>}
		###
		@tables = 
			parent: parent
			child: child
		
		###*
	  * @type {Object.<string, string>}
		###
		@cardinality_ =
			parent: '1'
			child: 'n'

		###*
	  * @type {Object.<string, number>}
		###
		@modality_ =
			parent: if identify  then 1 else 0
			child: 0

	###*
	* @param {boolean} identify True if relation is identyfing
	###
	setType: (identify) ->
		@identifying_ = identify

		@dispatchEvent 'type-change'
		
	###*
  * @param {string} name
	###
	setName: (name) ->
		@name_ = name	

	###*
  * @return {string}
	###
	getName: ->
		@name_

	setCardinalityAndModality: (cardinality, modality) ->
		@cardinality_ = cardinality
		@modality_ = modality

		@dispatchEvent 'cardinality-change'

	getCardinalityAndModality: ->
		cardinality: @cardinality_
		modality: @modality_			

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

	###*
	* @return {Array.<Object.<string,number>>}
	###
	getColumnsMapping: ->
		@keyColumnsMapping_
	
	###*
  * @param {?string=} parent
  * @param {?string=} child
  * @return {(string|null)}
	###
	getOppositeMappingId: (parent, child) ->
		if parent?
			key = 'parent'
			oppositeKey = 'child'
			id = parent
		else if child?
			key = 'child'
			oppositeKey = 'parent'
			id = child
		else
			console.warn 'Get opposite mapping column id: no column id passed'
			return null

		for mapping in @keyColumnsMapping_ when mapping[key] is id
			return mapping[oppositeKey]

	###*
  * @param {?string} parent Name of parent table
  * @param {?string=} child Name of child table
	###
	###
	setRelatedTables: (parent, child) =>
		if parent? then @tables.parent = parent
		if child? then @tables.child = child
	###

	###*
	* Since relation model contains "only" ids of tables, its names have to be
	*  passed
	*
	* @param {string} parentName
	* @param {string} childName
	* @return {Object} table model at JSON representation
	###
	toJSON: (parentName, childName) ->
		'type': @identifying_
		'name': @name_
		'mapping': @keyColumnsMapping_
		'tables': 
			parent: parentName
			child: childName
		'cardinality': @cardinality_
		'modality': @modality_

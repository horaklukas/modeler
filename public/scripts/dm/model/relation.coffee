goog.provide 'dm.model.Relation'

goog.require 'goog.events.EventTarget'

class dm.model.Relation extends goog.events.EventTarget
	###*
  * @param {boolean} identify True if relation is identifying
  * @constructor
  * @extends {goog.events.EventTarget}
	###
	constructor: (identify) ->
		super()
		#@setRelatedTables startTab, endTab
		
		###*
    * @type {boolean}
		###
		@identifying_ = identify

		###*
    * @type {Array.<number>} 
		###
		@fkColumnsIds_ = []

	###
	setRelatedTables: (parent, child) =>
		@startTab = parent
		@endTab = child
	###
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
  * Saves ids of child table columns that are foreign keys
  * @param {Array.<number>} ids
	###
	setFkColumnsIds: (ids) ->
		@fkColumnsIds_ = ids

	###
	* @return {Array.<number>}
	###
	getFkColumnsIds: ->
		@fkColumnsIds_

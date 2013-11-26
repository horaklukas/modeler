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
		
		@identifying_ = identify

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
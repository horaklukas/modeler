goog.provide 'dm.model.TableColumn'

class dm.model.TableColumn
	###*
  * @param {string} name
  * @param {string} type
  * @param {boolean} pk
  * @param {boolean} notnull
  * @param {boolean} unique
  * @param {boolean} fk
	###
	constructor: (name, type, pk, notnull, unique, fk) ->
		@name_ = name
		@type_ = type
		@pk_ = pk
		@notnull_ = notnull
		@unique_ = unique

	###*
  * @return {string}
  ###
	getName: ->
		@name_

	###*
  * @return {string}
  ###
	getType: ->
		@type_

	###*
  * @return {boolean}
  ###
	isPrimary: ->
		Boolean @pk_

	###*
  * @return {boolean}
  ###
	isNotNull: ->
		Boolean @notnull_

 	###*
  * @return {boolean}
  ###
	isUnique: ->
		Boolean @unique_ 

	###*
  * @return {dm.model.TableColumn} new instance of table column with same
  *  values as this instance
	###
	clone: ->
		new dm.model.TableColumn @getName(), @getType(), @isPrimary(), @isNotNull(), @isUnique()


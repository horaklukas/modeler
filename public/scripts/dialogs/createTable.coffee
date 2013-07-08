goog.provide 'dm.dialogs.CreateTableDialog'

goog.require 'dm.dialogs.CommonDialog'
goog.require 'tmpls.dialogs.createTable'
goog.require 'goog.dom'
goog.require 'goog.soy'
goog.require 'goog.events'
goog.require 'goog.dom.classes'
goog.require 'goog.array'

class dm.dialogs.CreateTableDialog extends dm.dialogs.CommonDialog
	constructor: (@types) ->
		super 'createTable', types
		@columnsCount = 0
		@nameField = goog.dom.getElement 'table_name'
		@colslist = goog.dom.getElement 'columns_list'

		btns = goog.dom.getElementsByTagNameAndClass 'button', null, @colslist
		addBtn = btns[0]
		
		click = goog.events.EventType.CLICK

		goog.events.listen addBtn, click, @addColumn

		goog.events.listen @colslist, click, (e) =>
			if goog.dom.classes.has e.target, 'delete' then @removeColumn e.target

		okBtn = goog.dom.getElementsByTagNameAndClass 'button', 'ok', @dialog
		cancBtn = goog.dom.getElementsByTagNameAndClass 'button', 'cancel', @dialog
		
		goog.events.listen okBtn[0], click, @confirm
		goog.events.listen cancBtn[0], click, @hide

	###*
	* Show the dialog window
	###
	show: (table) ->
		@relatedTable = table
		super()

	###*
	* Return all `columns` in dialog that have filled name, columns with empty
	* name are skipped
	*
	* @return {Array.<Object>} List of columns's objects, each object has
	* property `name`, `type` and `pk`  
	###
	getColumns: ->
		cols = goog.dom.getElementsByTagNameAndClass undefined, 'row', @colslist

		colsValues = goog.array.map cols, (elem) ->
			if goog.dom.classes.has elem, 'head' then return null
			
			name = goog.dom.getElementsByTagNameAndClass(undefined, 'name', elem)[0]

			# Columns with empty name dont
			if not name.value? or name.value is '' then return null 
			
			[type] = goog.dom.getElementsByTagNameAndClass(undefined, 'type', elem)
			[pkey] = goog.dom.getElementsByTagNameAndClass(undefined, 'pkey', elem)

			# Each column values
			name: name.value, type: type.value, pk: pkey.value 

		goog.array.filter colsValues, (elem) -> elem?

	###*
	* Return table name, filled in dialog
	*
	* @return {string} Table name
	###
	getName: ->
		@nameField.value

	###*
	* Set table values (name and columns) to dialog, used when editing table
	*
	* @param {string=} name
	* @param {Array.<Object>=} cols
	###
	setValues: (name = '', cols = []) ->
		goog.dom.setProperties @nameField, 'value': name

		# one more empty column for add at the end
		cols2set = cols.concat [{ name: '', type: null, pk: false }]

		# select all rows and remove then except first, which is titles row 
		oldcols = goog.dom.getElementsByTagNameAndClass	undefined, 'row', @colslist
		goog.dom.removeNode oldcol for oldcol in goog.array.slice oldcols, 1

		@addColumn col.name, col.type, col.pk for col in cols2set

	###*
	* Add new `column` row to dialog, empty or set in depend if values are passed
	*
	* @param {string=} name
	* @param {string=} type
	* @param {boolean=} pk
	###
	addColumn: (name, type, pk) =>
		opts = types: @types

		if name? and typeof name is 'string' then opts.name = name
		if type? and typeof type is 'string' then opts.colType = type
		if pk? then opts.pkey = pk

		col = goog.soy.renderAsElement tmpls.dialogs.createTable.tableColumn, opts
		goog.dom.appendChild @colslist, col

		@columnsCount++

	removeColumn: (deleteBtn) =>
		columnRow = goog.dom.getAncestorByClass deleteBtn, 'row'

		# last row isnt removed, only cleaned
		if @columnsCount is 1 then @addColumn()

		goog.dom.removeNode columnRow
		@columnsCount--

	onConfirm: (cb) ->
		@confirmCb = cb

	confirm: =>
		if @confirmCb?
			tabName = @getName()
			columns = @getColumns()	

			@confirmCb @relatedTable, tabName, columns
		@hide()
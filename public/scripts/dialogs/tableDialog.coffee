goog.provide 'dm.dialogs.TableDialog'
goog.provide 'dm.dialogs.TableDialog.Confirm'

goog.require 'goog.ui.Dialog'
goog.require 'tmpls.dialogs.createTable'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.soy'
goog.require 'goog.events'
goog.require 'goog.array'

class dm.dialogs.TableDialog extends goog.ui.Dialog
	constructor: (@types) ->
		super() #'createTable', types
		
		@setContent tmpls.dialogs.createTable.dialog {types: types}
		@setButtonSet goog.ui.Dialog.ButtonSet.OK_CANCEL
		@setDraggable false

		# force render dialog, so all control widgets exists since now
		content = @getContentElement()
		
		addBtn = goog.dom.getElementsByTagNameAndClass('button', 'add', content)[0]
		@nameField = goog.dom.getElement 'table_name'
		@colslist = goog.dom.getElement 'columns_list'

		# events 1) add new column 2) delete existing column 3) dialog ok or cancel
		goog.events.listen addBtn, goog.events.EventType.CLICK, @addColumn

		goog.events.listen @colslist, goog.events.EventType.CLICK, (e) =>
			if goog.dom.classes.has e.target, 'delete' then @removeColumn e.target	

		goog.events.listen @, goog.ui.Dialog.EventType.SELECT, @onSelect

	###*
	* Show the dialog window
	###
	show: (table) ->
		@relatedTable = table
		@columnsCount = 0

		@setVisible true

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
			[nnull] = goog.dom.getElementsByTagNameAndClass(undefined, 'nnull', elem)
			[uniq] = goog.dom.getElementsByTagNameAndClass(undefined, 'unique', elem)

			# Each column values
			name: name.value
			type: type.value
			pk: pkey.checked
			nnull: nnull.checked
			uniq: uniq.checked 

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
		cols2set = cols.concat [
			{ name: '', type: null, pk: false, nnull: false, uniq: false }
		]

		# select all rows and remove then except first, which is titles row 
		oldcols = goog.dom.getElementsByTagNameAndClass	undefined, 'row', @colslist
		goog.dom.removeNode oldcol for oldcol in goog.array.slice oldcols, 1

		for col in cols2set
			@addColumn col.name, col.type, col.pk, col.nnull, col.uniq

	###*
	* Add new `column` row to dialog, empty or set in depend if values are passed
	*
	* @param {string=} name
	* @param {string=} type
	* @param {boolean=} pk
	* @param {boolean=} nnull
	* @param {boolean=} uniq
	###
	addColumn: (name, type, pk, nnull, uniq) =>
		opts = types: @types

		if name? and typeof name is 'string' then opts.name = name
		if type? and typeof type is 'string' then opts.colType = type
		if pk? then opts.pkey = pk
		if nnull? then opts.nnull = nnull
		if uniq? then opts.uniq  = uniq

		col = goog.soy.renderAsElement tmpls.dialogs.createTable.tableColumn, opts
		goog.dom.appendChild @colslist, col

		@columnsCount++

	removeColumn: (deleteBtn) =>
		columnRow = goog.dom.getAncestorByClass deleteBtn, 'row'

		# last row isnt removed, only cleaned
		if @columnsCount is 1 then @addColumn()

		goog.dom.removeNode columnRow
		@columnsCount--

	onSelect: (e) =>
		if e.key isnt 'ok' then return true

		tabName = @getName()
		columns = @getColumns()	
		
		confirmEvent =  new dm.dialogs.TableDialog.Confirm(@, @relatedTable, tabName, columns)

		@dispatchEvent confirmEvent

dm.dialogs.TableDialog.EventType =
	CONFIRM: goog.events.getUniqueId 'dialog-confirmed'

class dm.dialogs.TableDialog.Confirm extends goog.events.Event
	constructor: (dialog, id, name, columns) ->
		super dm.dialogs.TableDialog.EventType.CONFIRM, dialog

		###*
    * @type {string}
		###
		@tableId = id
		
		###*
    * @type {string}
		###
		@tableName = name

		###*
    * @type {Array.<Object>}
		###
		@tableColumns = columns
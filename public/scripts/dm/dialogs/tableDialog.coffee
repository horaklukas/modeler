goog.provide 'dm.dialogs.TableDialog'
goog.provide 'dm.dialogs.TableDialog.Confirm'

goog.require 'goog.ui.Dialog'
goog.require 'tmpls.dialogs.createTable'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.dom.query'
goog.require 'goog.soy'
goog.require 'goog.events'
goog.require 'goog.array'
goog.require 'goog.object'
goog.require 'goog.string'

class dm.dialogs.TableDialog extends goog.ui.Dialog
	@EventType =
		CONFIRM: goog.events.getUniqueId 'dialog-confirmed'

	constructor: () ->
		super() #'createTable', types
		
		@setContent tmpls.dialogs.createTable.dialog {types: DB.types}
		@setButtonSet goog.ui.Dialog.ButtonSet.OK_CANCEL
		@setDraggable false

		# force render dialog, so all control widgets exists since now
		content = @getContentElement()
		
		addBtn = goog.dom.getElementsByTagNameAndClass('button', 'add', content)[0]
		@nameField = goog.dom.getElement 'table_name'
		@colslist = goog.dom.getElement 'columns_list'

		@columns_ = removed: null, added: null, updated: null, count: 0

		# events 1) add new column 2) delete existing column 3) dialog ok or cancel
		goog.events.listen addBtn, goog.events.EventType.CLICK, @addColumn

		goog.events.listen @colslist, goog.events.EventType.CLICK, (e) =>
			if goog.dom.classes.has e.target, 'delete' then @removeColumn e.target	

		goog.events.listen @, goog.ui.Dialog.EventType.SELECT, @onSelect

	###* @override ###
	#enterDocument: ->
	#	super()

	###*
	* Show the dialog window
	* @param {boolean} show 
	* @param {dm.ui.Table=} table
	###
	show: (show, table) ->
		if table?
			@table_ = table
			model = table.getModel()
			columns = model.getColumns() 

			@columns_ = 
				# prepared empty row is counted as the first `added`
				removed:[], updated:[], added:[columns.length], count:columns.length

			@setValues model.getName(), columns

			# @TODO change of inputs of rows added from model
			rows = goog.dom.getChildren @colslist
			
			# each row except first (head row) and last (empty row) is row that 
			# from original model, so its change is update
			for i in [1..rows.length - 2]
				row = rows[i]
				goog.events.listen row, goog.events.EventType.CHANGE, (e) =>
					columnRow = goog.dom.getAncestorByClass e.target, 'row'
					index = goog.string.toNumber columnRow.getAttribute 'name'
					# dont add column that already exists there 
					unless index in @columns_.updated then @columns_.updated.push index
		
		@setVisible show

	###*
	* @param {number} index Column index
  * @return {dm.model.TableColumn} model of columns with passed index
	###
	getColumnModel: (index) ->
		column = goog.dom.query "*[name='#{index}']", @colslist
			
		# that should never throw
		if column.length is 0 then throw new Error 'Column not exist!'

		# query returns node list, column element have to be selected
		[column] = column

		name: goog.dom.getElementByClass('name', column).value
		type: goog.dom.getElementByClass('type', column).value
		isPk: goog.dom.getElementByClass('primary', column).checked
		isNotNull:goog.dom.getElementByClass('notnull', column).checked
		isUnique:goog.dom.getElementByClass('unique', column).checked

	###*
	* Return table name, filled in dialog
	* @return {string} Table name
	###
	getName: ->
		@nameField.value

	###*
	* Set table values (name and columns) to dialog, used when editing table
	*
	* @param {string=} name
	* @param {Array.<dm.model.Table>=} cols
	###
	setValues: (name = '', cols = []) ->
		goog.dom.setProperties @nameField, 'value': name

		@colslist.innerHTML = tmpls.dialogs.createTable.columnsList {
			types: DB.types, columns: cols
		}
	###*
	* Add new `column` row to dialog, empty or set in depend if values are passed
	*
	* @param {dm.model.TableColumn} column
	###
	addColumn: (column) =>
		opts = types: DB.types
		
		@columns_.count++
		opts.id = @columns_.count

		###
		if column?
			if goog.isString(column.name) then opts.name = column.name
			if goog.isString(column.type) then opts.type = column.type
			if column.isPk? then opts.isPk = column.isPk
			if column.isNotNull? then opts.isNotNull = column.isNotNull
			if column.isUnique? then opts.isUnique = column.isUnique
		###

		@colslist.innerHTML += tmpls.dialogs.createTable.tableColumn opts

		@columns_.added.push @columns_.count

	###*
  * @param {Element} deleteBtn Button element that invoked action
	###
	removeColumn: (deleteBtn) =>
		columnRow = goog.dom.getAncestorByClass deleteBtn, 'row'
		index = goog.string.toNumber columnRow.getAttribute 'name'

		# if removing column isnt in model yet only remove column id from ids
		# prepared to add
		if index in @columns_.added then goog.array.remove @columns_.added, index
		else @columns_.removed.push index

		goog.dom.removeNode columnRow

	###*
  * @param {goog.events.Event} e
	###
	onSelect: (e) =>
		if e.key isnt 'ok' then return true

		model = @table_.getModel()

		model.setName @getName()

		model.setColumn @getColumnModel(id), id for id in @columns_.updated
		model.removeColumn id for id in @columns_.removed
		
		# add columns that have filled name
		for id in @columns_.added
			colmodel = @getColumnModel(id) 
			if colmodel.name? and colmodel.name isnt '' then model.setColumn colmodel

		#@table_.setModel model
		#confirmEvent =  new dm.dialogs.TableDialog.Confirm(@, @relatedTable, tabName, columns)

		#@dispatchEvent confirmEvent

goog.addSingletonGetter dm.dialogs.TableDialog

###
class dm.dialogs.TableDialog.Confirm extends goog.events.Event
	constructor: (dialog, id, name, columns) ->
		super dm.dialogs.TableDialog.EventType.CONFIRM, dialog
###
###*
* @type {string}
###
#@tableId = id

###*
* @type {string}
###
#@tableName = name

###*
* @type {Array.<Object>}
###
#@tableColumns = columns
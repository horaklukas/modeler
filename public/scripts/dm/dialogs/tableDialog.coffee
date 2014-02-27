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
goog.require 'dm.model.Table'

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
			columnsCount = model.getColumns().length

			@columns_ = 
				# prepared empty row is counted as the first `added`
				removed: [], updated: [], added: [columnsCount], count: columnsCount

			@setValues model
			@setTitle "Table \"#{model.getName()}\""

			# @TODO change of inputs of rows added from model
			rows = goog.dom.getChildren @colslist
			
			# each row except first (head row) and last (empty row) is row that is
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
	getColumnData: (index) ->
		column = goog.dom.query "*[name='#{index}']", @colslist
			
		# that should never throw
		if column.length is 0 then throw new Error 'Column not exist!'

		# query returns node list, column element have to be selected
		[column] = column

		model:
			name: goog.dom.getElementByClass('name', column).value.replace ' ', '_'
			type: goog.dom.getElementByClass('type', column).value
			isNotNull:goog.dom.getElementByClass('notnull', column).checked
		isPk: goog.dom.getElementByClass('primary', column).checked
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
	* @param {dm.model.Table=} model
	###
	setValues: (model) ->
		name = model.getName() ? ''
		cols = model.getColumns() ? []
		uniqs = model.getColumnsIdsByIndex dm.model.Table.index.UNIQUE
		pks = model.getColumnsIdsByIndex dm.model.Table.index.PK
		fks = model.getColumnsIdsByIndex dm.model.Table.index.FK

		goog.dom.setProperties @nameField, 'value': name

		for col, id in cols
			if id in uniqs then cols[id].isUnique = true 
			if id in pks then cols[id].isPk = true
			if id in fks then cols[id].isFk = true

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

		# update earlie created columns and its indexes
		for id in @columns_.updated
			colData = @getColumnData(id)
			model.setColumn colData.model, id
			model.setIndex id, dm.model.Table.index.UNIQUE, not colData.isUnique
			model.setIndex id, dm.model.Table.index.PK, not colData.isPk
		
		# removed deleted columns
		model.removeColumn id for id in @columns_.removed
		
		# add columns (and its indexes) that have filled name
		for id in @columns_.added
			colData = @getColumnData(id) 
			
			if not colData.model.name? or colData.model.name is '' then continue
				
			colId = model.setColumn colData.model
			if colData.isUnique then model.setIndex colId, dm.model.Table.index.UNIQUE
			if colData.isPk then model.setIndex colId, dm.model.Table.index.PK


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
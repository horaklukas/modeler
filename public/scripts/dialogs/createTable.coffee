class createTableDialog extends CommonDialog
	constructor: (@types) ->
		super 'createTable', types
		@$name = $('[name=physical_name]', @dialog)
		@$colslist = $('#columns_list', @dialog)

		$('button:first', @$colslist).on  'click', @addColumn
		@$colslist.on 'click', '.delete', @removeColumn
		@dialog.on 'click', 'button.ok', @confirm
		@dialog.on 'click', 'button.cancel', @hide

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
		$cols = $('.row:not(.head)', @$colslist)
		
		$.map $cols, (elem, val) ->
			$this = $(elem)
			name = $('[name=name]', $this).prop 'value'

			# Columns with empty name dont
			if not name? or name is '' then return null 
			else
				# Each column values
				name: name, type: $('[name=type]', $this).prop 'value'
				pk: $('.pkey', $this).prop 'checked'

	###*
	* Return table name, filled in dialog
	*
	* @return {string} Table name
	###
	getName: ->
		@$name.prop 'value'

	###*
	* Set table values (name and columns) to dialog, used when editing table
	*
	* @param {string=} name
	* @param {Array.<Object>=} cols
	###
	setValues: (name = '', cols = []) ->
		@$name.prop 'value', name

		# one more empty column for add at the end
		cols2set = cols.concat [{ name: '', type: null, pk: false }]

		$('.row:not(.head)', @$colslist).remove()
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

		@$colslist.append tmpls.dialogs.createTable.tableColumn opts

	removeColumn: (ev) =>
		$row = $(ev.target).closest '.row'

		# last row isnt removed, only cleaned
		unless $row.siblings('.row:not(.head)').length then @addColumn()

		$row.remove()

	onConfirm: (cb) ->
		@confirmCb = cb

	confirm: =>
		if @confirmCb?
			tabName = @getName()
			columns = @getColumns()	

			@confirmCb @relatedTable, tabName, columns
		@hide()
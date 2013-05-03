class createTableDialog extends CommonDialog
	constructor: (@types) ->
		super 'createTable', types
		@$name = $('[name=physical_name]', @dialog)
		@$colslist = $('#columns_list', @dialog)

		$('button:first', @$colslist).on  'click', @addColumn
		@dialog.on 'click', 'button.ok', @confirm
		@dialog.on 'click', 'button.cancel', @hide

	show: (table) ->
		@relatedTable = table
		super()

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

	setColumns: (cols) ->
		$('.row:not(.head)', @$colslist).remove()
		@addColumn col.name, col.pk for col in cols

	addColumn: (name, pk) =>
		opts = types: @types  
		if name? and typeof name is 'string' then opts.name = name
		if pk? then opts.pk = pk

		@$colslist.append tmpls.dialogs.createTable.tableColumn opts

	onConfirm: (cb) ->
		@confirmCb = cb

	confirm: =>
		if @confirmCb?
			tabName = @$name.prop 'value'
			columns = @getColumns()	

			@confirmCb @relatedTable, tabName, columns
		@hide()
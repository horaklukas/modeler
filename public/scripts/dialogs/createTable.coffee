class createTableDialog extends CommonDialog
	constructor: (types) ->
		super 'createTable', types
		@$name = $('[name=physical_name]', @dialog)

		@dialog.on 'click', 'button.ok', @passValsToCallback
		@dialog.on 'click', 'button.cancel', @hide

	show: (table) ->
		@relatedTable = table
		super()

	onConfirm: (cb) ->
		@confirmCb = cb

	passValsToCallback: =>
		if @confirmCb? then @confirmCb @relatedTable, @$name.prop('value')
		@hide()
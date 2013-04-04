class createTableDialog extends CommonDialog
	constructor: ->
		super 'createTable'
		@$name = $('[name=physical_name]', @dialog)
		@$ok = $('.ok', @dialog)
		@$cancel = $('.cancel', @dialog)

		@$ok.on 'click', @passValsToCallback
		@$cancel.on 'click', @hide

	show: (table) ->
		@relatedTable = table
		super()

	onConfirm: (cb) ->
		@confirmCb = cb

	passValsToCallback: =>
		if @confirmCb? then @confirmCb @relatedTable, @$name.prop('value')
		@hide()
class CommonDialog
	constructor: (name, types) ->
		@dialog = $('#'+name)
		
		unless @dialog.length
			@dialog = jQuery tmpls.dialogs[name].dialog {types: types}
			@dialog.appendTo App.$elem

	show: =>
		@dialog.addClass 'active'

	hide: =>
		@dialog.removeClass 'active'
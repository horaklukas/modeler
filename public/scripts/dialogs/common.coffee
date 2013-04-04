class CommonDialog
	constructor: (id) ->
		@dialog = $('#'+id)

	show: =>
		@dialog.addClass 'active'

	hide: =>
		@dialog.removeClass 'active'
goog.provide 'dm.dialogs.CommonDialog'

#goog.require 'tmpls.dialogs'

class dm.dialogs.CommonDialog
	constructor: (name, types) ->
		@dialog = $('#'+name)
		
		unless @dialog.length
			@dialog = jQuery tmpls.dialogs[name].dialog {types: types}
			@dialog.appendTo dm.$elem

	show: =>
		@dialog.addClass 'active'

	hide: =>
		@dialog.removeClass 'active'
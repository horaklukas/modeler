goog.provide 'dm.dialogs.CommonDialog'

goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.events.EventTarget'

class dm.dialogs.CommonDialog extends goog.events.EventTarget
	constructor: (name, types) ->
		super()
		@dialog = goog.dom.getElement name
		
		unless goog.isDefAndNotNull @dialog
			@dialog = goog.soy.renderAsElement( 
				tmpls.dialogs[name].dialog,
				{types: types}
			)
			
			goog.dom.appendChild dm.$elem, @dialog

	show: =>
		goog.dom.classes.add @dialog, 'active'

	hide: =>
		goog.dom.classes.remove @dialog, 'active'
goog.provide 'dm.dialogs.RelationDialog'
goog.provide 'dm.dialogs.RelationDialog.Confirm'

goog.require 'goog.ui.Dialog'
goog.require 'tmpls.dialogs.createRelation'
goog.require 'goog.dom'
goog.require 'goog.soy'
goog.require 'goog.string'
goog.require 'goog.events'

class dm.dialogs.RelationDialog extends goog.ui.Dialog
	constructor: (@types) ->
		super()
		
		@isIdentifying = false

		@setContent tmpls.dialogs.createRelation.dialog false
		@setButtonSet goog.ui.Dialog.ButtonSet.OK_CANCEL
		@setDraggable false

		# force render dialog, so all control widgets exists since now
		content = @getContentElement()
		
		@relTypeForm = goog.dom.getElement 'reltype'

		# events 1) change identifying of relation 2) dialog ok or cancel
		goog.events.listen @relTypeForm, goog.events.EventType.CHANGE, @setIdentifying

		goog.events.listen @, goog.ui.Dialog.EventType.SELECT, @onSelect

	###*
	* If change type of relation (identifying or non-identifying) then save
	* actual value 
	###
	setIdentifying: (ev) =>
		@isIdentifying = Boolean goog.string.toNumber ev.target.value

	show: (relation) ->
		@relatedRelation = relation
		@setVisible true 

	onSelect: (e) =>
		if e.key isnt 'ok' then return true
		
		confirmEvent =  new dm.dialogs.RelationDialog.Confirm(@, @relatedRelation, @isIdentifying)

		@dispatchEvent confirmEvent

	setValues: (ident = false) ->
		newRelTypeForm = goog.soy.renderAsFragment tmpls.dialogs.createRelation.identform, {ident: ident}
		goog.dom.replaceNode @relTypeForm, newRelTypeForm


dm.dialogs.RelationDialog.EventType =
	CONFIRM: goog.events.getUniqueId 'dialog-confirmed'

class dm.dialogs.RelationDialog.Confirm extends goog.events.Event
	constructor: (dialog, id, ident) ->
		super dm.dialogs.RelationDialog.EventType.CONFIRM, dialog

		###*
    * @type {string}
		###
		@relationId = id

		###*
    * @type {boolean}
		###
		@identifying = ident
goog.provide 'dm.dialogs.RelationDialog'
goog.provide 'dm.dialogs.RelationDialog.Confirm'

goog.require 'goog.ui.Dialog'
goog.require 'tmpls.dialogs.createRelation'
goog.require 'goog.dom'
goog.require 'goog.soy'
goog.require 'goog.string'
goog.require 'goog.events'

class dm.dialogs.RelationDialog extends goog.ui.Dialog
	EventType =
		CONFIRM: goog.events.getUniqueId 'dialog-confirmed'

	constructor: (@types) ->
		super()
		
		@isIdentifying = false
		@relatedTables = parent: null, child: null

		@setContent tmpls.dialogs.createRelation.dialog false
		@setButtonSet goog.ui.Dialog.ButtonSet.OK_CANCEL
		@setDraggable false

		# force render dialog, so all control widgets exists since now
		content = @getContentElement()
		
		@relPrefsForm = goog.dom.getElement 'relprefs'

		# events 1) change identifying of relation 2) dialog ok or cancel
		goog.events.listen @relPrefsForm, goog.events.EventType.CHANGE, @setIdentifying

		goog.events.listen @relPrefsForm, goog.events.EventType.SUBMIT, @swapParentChild

		goog.events.listen @, goog.ui.Dialog.EventType.SELECT, @onSelect

	###*
	* If change type of relation (identifying or non-identifying) then save
	* actual value 
	###
	setIdentifying: (ev) =>
		@isIdentifying = Boolean goog.string.toNumber ev.target.value

	swapParentChild: (ev) =>
		# swap ids
		tmp = @relatedTables.parent

		@relatedTables.parent = @relatedTables.child
		@relatedTables.child = tmp

		# swap tables names in dialog
		parent = goog.dom.getElementByClass 'parent', ev.target
		child = goog.dom.getElementByClass 'child', ev.target

		tmp = goog.dom.getTextContent parent

		goog.dom.setTextContent parent, goog.dom.getTextContent child
		goog.dom.setTextContent child, tmp

		ev.preventDefault()

	show: (relation) ->
		@relatedRelation = relation
		@setVisible true 

	onSelect: (e) =>
		if e.key isnt 'ok' then return true
		
		confirmEvent =  new dm.dialogs.RelationDialog.Confirm(@, @relatedRelation, @isIdentifying, @relatedTables.parent, @relatedTables.child)

		@dispatchEvent confirmEvent

	###*
	* @param {dm.model.Table} parent
	* @param {dm.model.Table} child
	* @param {boolean=} ident 
	###
	setValues: (parent, child, ident = false) ->
		values =
			ident: ident, parentTable: parent.getName(), childTable: child.getName()

		@isIdentifying = ident
		@relatedTables.parent = dm.actualModel.getTable parent.id 
		@relatedTables.child = dm.actualModel.getTable child.id

		goog.soy.renderElement @relPrefsForm, tmpls.dialogs.createRelation.prefs, values

class dm.dialogs.RelationDialog.Confirm extends goog.events.Event
	constructor: (dialog, id, ident, parenttab, childtab) ->
		super dm.dialogs.RelationDialog.EventType.CONFIRM, dialog

		###*
    * @type {string}
		###
		@relationId = id

		###*
    * @type {boolean}
		###
		@identifying = ident

		###*
    * @type {string}
		###
		@parentTable = parenttab

		###*
    * @type {string}
		###
		@childTable = childtab
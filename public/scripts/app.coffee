goog.provide 'dm'
goog.provide 'dm.init'

goog.require 'dm.dialogs.TableDialog'
goog.require 'dm.dialogs.RelationDialog'
goog.require 'dm.model.Model'
goog.require 'dm.ui.Canvas'
goog.require 'dm.ui.ControlPanel'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.events'

dm.init = ->
	dm.$elem = goog.dom.getElement 'app'
	dm.tableDialog = new dm.dialogs.TableDialog DB.types
	dm.relationDialog = new dm.dialogs.RelationDialog()

	dm.actualModel = new dm.model.Model 'Model1'
	 
	canvas = dm.ui.Canvas.getInstance()
	canvas.init 'modelerCanvas'
	dm.ui.ControlPanel.getInstance().init goog.dom.getElement 'controlPanel'

	goog.events.listen dm.tableDialog, dm.dialogs.TableDialog.EventType.CONFIRM, (ev) ->
			dm.actualModel.setTable ev.tableId, ev.tableName, ev.tableColumns

	goog.events.listen dm.relationDialog, dm.dialogs.RelationDialog.EventType.CONFIRM, (ev) ->
			dm.actualModel.setRelation ev.relationId, ev.identifying

	# Some test objects
	tab0 = dm.actualModel.addTable canvas.html, 100, 75
	dm.actualModel.setTable tab0, 'Person', [
		{ name: 'person_id', type: 'smallint', pk: true }
		{ name: 'name', type: 'character varying', pk: false }
	]

	tab1 = dm.actualModel.addTable canvas.html, 500, 280
	dm.actualModel.setTable tab1, 'Account', [
		{ name: 'account_id', type: 'smallint', pk: true }
		{ name: 'account_number', type: 'numeric', pk: false }
	]

	tab2 = dm.actualModel.addTable canvas.html, 100, 280
	dm.actualModel.setTable tab2, 'PersonAccount'

	tab3 = dm.actualModel.addTable canvas.html, 600, 50
	dm.actualModel.setTable tab3, 'AccountType', [
		{ name: 'acctype_id', type: 'smallint', pk: true }
		{ name: 'code', type: 'numeric', pk: false }
		{ name: 'name', type: 'character varying', pk: false }
		{ name: 'description', type: 'character varying', pk: false }	
	]

	tab4 = dm.actualModel.addTable canvas.html, 900, 50
	dm.actualModel.setTable tab4, 'BigSizeTable', [
		{ name: 'first_long_pk_column', type: 'smallint', pk: true }
		{ name: 'second_long_row', type: 'numeric', pk: false }
		{ name: 'third_row_that_is_long', type: 'numeric', pk: false }
		{ name: 'description', type: 'character varying', pk: false }	
		{ name: 'code_long', type: 'numeric', pk: false }
		{ name: 'name_of_this_row', type: 'character varying', pk: false }
	]	

	tab5 = dm.actualModel.addTable canvas.html, 900, 250
	dm.actualModel.setTable tab5, 'SecondBigSizeTable', [
		{ name: 'first_long_pk_column', type: 'smallint', pk: true }
		{ name: 'second_long_row', type: 'numeric', pk: false }
		{ name: 'third_row_that_is_long', type: 'numeric', pk: false }
		{ name: 'description', type: 'character varying', pk: false }	
		{ name: 'code_long', type: 'numeric', pk: false }
		{ name: 'name_of_this_row', type: 'character varying', pk: false }
	]

	dm.actualModel.addRelation canvas.svg, tab0, tab2, true
	dm.actualModel.addRelation canvas.svg, tab1, tab2, true
	dm.actualModel.addRelation canvas.svg, tab1, tab3, false
	dm.actualModel.addRelation canvas.svg, tab4, tab5, false

goog.exportSymbol 'dm.init', dm.init
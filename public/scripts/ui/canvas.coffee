goog.provide 'dm.ui.Canvas'

goog.require 'goog.dom'
goog.require 'goog.style'
goog.require 'goog.events'
goog.require 'goog.events.EventTarget'

class dm.ui.Canvas extends goog.events.EventTarget
	###*
  * @constructor
  * @extends {goog.events.EventTarget}
	###
	constructor: ->
		super()

	###*
  * @param {string} canvasId Id of element to init canvas on
	###
	init: (canvasId) ->
		@html = goog.dom.getElement canvasId
		{@width, @height} = goog.style.getSize @html

		@svg = Raphael canvasId, @width, @height

		@clueTable = @svg.rect 0, 0, 100, 80, 2 
		@clueTable.attr(fill:'#CCC', opacity: 0.5).hide()

		goog.events.listen @, goog.events.EventType.DBLCLICK, @onDblClick

	###*
  * @param {goog.events.Event} ev
  ###
	onDblClick: (ev) =>
		table = goog.dom.getAncestorByClass ev.target, 'table'

		if table then @clickedTable table

	###*
  * @param {dm.model.Table} table
 	###
	clickedTable: (table) ->
		tid = table.id
		tab = dm.actualModel.getTable tid

		dm.tableDialog.show tid
		dm.tableDialog.setValues tab.getName(), tab.getColumns()

	moveTable: (ev) =>
		position = goog.style.getRelativePosition ev, @html
		@clueTable.show().attr 'x': position.x, 'y': position.y

	###*
  * @param {goog.math.Coordinate} tabPos
	###	
	placeTable: (tabPos) => 
		id = dm.actualModel.addTable @html, tabPos.x, tabPos.y
		@clueTable.hide()

		dm.tableDialog.setValues()
		dm.tableDialog.show id

	###*
  * @param {goog.math.Coordinate} startCoords
	###
	setStartRelationPoint: (startCoords)->
		@startRelationPath = "M#{startCoords.x} #{startCoords.y}"
		@clueRelation = @svg.path @startRelationPath
		@clueRelation.show()

	moveEndRelationPoint:(ev) =>
		point = goog.style.getRelativePosition ev, @html

		@clueRelation.attr 'path', "#{@startRelationPath}L#{point.x} #{point.y}"

	placeRelation: (endCoords) =>
		@clueRelation.hide()
		@startRelationPath = undefined

		

goog.addSingletonGetter dm.ui.Canvas
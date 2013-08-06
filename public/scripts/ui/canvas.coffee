goog.provide 'dm.ui.Canvas'
goog.provide 'dm.ui.Canvas.Click'

goog.require 'goog.dom'
goog.require 'goog.style'
goog.require 'goog.events'
goog.require 'goog.events.EventTarget'
goog.require 'goog.graphics'
goog.require 'goog.graphics.SvgGraphics'
goog.require 'goog.graphics.Stroke'
goog.require 'goog.graphics.SolidFill'
goog.require 'goog.graphics.Path'

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
		# @FIXME - remove this row and set height from document viewport height 
		if @height is 0 then @height = 768
		
		@svg = new goog.graphics.SvgGraphics @width, @height
		@svg.render @html

		stroke = new goog.graphics.Stroke 2, '#000'
		fill = new goog.graphics.SolidFill '#CCC'
		@clueTable = @svg.drawRect 0, 0, 100, 80, stroke, fill

		clueTabElement = @clueTable.getElement()
		goog.style.setOpacity clueTabElement, 0.5
		goog.style.showElement clueTabElement, false 

		goog.events.listen @html, goog.events.EventType.DBLCLICK, @onDblClick
		goog.events.listen @svg, goog.events.EventType.DBLCLICK, @onDblClick
		goog.events.listen @html, goog.events.EventType.CLICK, @onClick

	###*
  * @param {goog.events.Event} ev
  ###
	onDblClick: (ev) =>
		table = goog.dom.getAncestorByClass ev.target, 'table'

		if table then @clickedTable table
		else if ev.target.nodeName is 'path' then @clickedRelation ev.target

	###*
  * @param {goog.events.Event} ev
  ###
	onClick: (ev) =>
		clickPos = goog.style.getRelativePosition ev, ev.currentTarget
		clickObj = goog.dom.getAncestorByClass ev.target, 'table'

		@dispatchEvent new dm.ui.Canvas.Click clickPos, clickObj

	###*
  * @param {HTMLElement} table
 	###
	clickedTable: (table) ->
		tid = table.id
		tab = dm.actualModel.getTable tid

		dm.tableDialog.show tid
		dm.tableDialog.setValues tab.getName(), tab.getColumns()

	moveTable: (ev) =>
		position = goog.style.getRelativePosition ev, @html
		
		goog.style.showElement @clueTable.getElement(), true
		@clueTable.setPosition position.x, position.y

	###*
  * @param {goog.math.Coordinate} tabPos
	###	
	placeTable: (tabPos) => 
		id = dm.actualModel.addTable @html, tabPos.x, tabPos.y
		goog.style.showElement @clueTable.getElement(), false

		dm.tableDialog.setValues()
		dm.tableDialog.show id

	###*
	# @param {SVGPath} relation 
	###
	clickedRelation: (relation) ->
		rid = relation.id
		rel = dm.actualModel.getRelation rid

		dm.relationDialog.show rid
		dm.relationDialog.setValues rel.isIdentifying()

	###*
  * @param {goog.math.Coordinate} startCoords
	###
	setStartRelationPoint: (startCoords)->
		@startRelationPath = new goog.graphics.Path()
		@startRelationPath.moveTo startCoords.x, startCoords.y
		
		if @clueRelation
			goog.style.showElement @clueRelation.getElement(), true
			@clueRelation.setPath @startRelationPath
		else
			stroke = new goog.graphics.Stroke 1, '#000'
			@clueRelation = @svg.drawPath @startRelationPath, stroke
			goog.style.showElement @clueRelation.getElement(), true

	moveEndRelationPoint:(ev) =>
		point = goog.style.getRelativePosition ev, @html

		newPath = @startRelationPath.clone()
		newPath.lineTo point.x, point.y
		
		@clueRelation.setPath newPath

	placeRelation: (endCoords, startTab, endTab) =>
		goog.style.showElement @clueRelation.getElement(), false
		@startRelationPath = undefined

		id = dm.actualModel.addRelation @svg, startTab, endTab

		dm.relationDialog.setValues()
		dm.relationDialog.show id

dm.ui.Canvas.EventType = 
	CLICK: goog.events.getUniqueId 'canvas-click'	

goog.addSingletonGetter dm.ui.Canvas

class dm.ui.Canvas.Click extends goog.events.Event
	constructor: (pos, obj) ->
		super dm.ui.Canvas.EventType.CLICK, dm.ui.Canvas.getInstance()

		###*
    * @type {goog.math.Coordinate}
		###
		@position = pos
		
		###*
    * @type {?HTMLElement}
		###
		@object = obj
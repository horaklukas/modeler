goog.provide 'dm.ui.Canvas'
goog.provide 'dm.ui.Canvas.Click'

goog.require 'goog.dom'
goog.require 'goog.style'
goog.require 'goog.events'
goog.require 'goog.graphics'
goog.require 'goog.graphics.SvgGraphics'
goog.require 'goog.graphics.Stroke'
goog.require 'goog.graphics.SolidFill'
goog.require 'goog.graphics.Path'
goog.require 'dm.ui.Table.EventType'

class dm.ui.Canvas extends goog.graphics.SvgGraphics
	@EventType = 
		OBJECT_EDIT: goog.events.getUniqueId 'object-edit'
		CLICK: goog.events.getUniqueId 'click'	

	###*
  * @constructor
  * @extends {goog.events.EventTarget}
	###
	constructor: ->
		super '100%', '100%'

		###*
    * @typedef {{object:(dm.ui.Table|dm.ui.Relation),offset:goog.math.Coordinate}}
		###
		@move = object: null, offset: null
		
		###*
    * @type {goog.math.Coordinate}
		###
		@size_ = null

		###*
    * @type {Element}
		###
		@rootElement_ = null

	###*
  * @override
	###	
	#createDom: ->
		#super()
		#svgCanvas = new goog.graphics.SvgGraphics() # @width, @height
		#svgCanvas = @getDomHelper().createDom 'svg'
		#@setElementInternal svgCanvas, {width: '100', height: '100'}

	###*
  * @override
	###
	enterDocument: ->
		super()
		@rootElement_ = goog.dom.getParentElement @getElement()
		@size_ = goog.style.getSize @rootElement_

		goog.events.listen @rootElement_, goog.events.EventType.DBLCLICK, @onDblClick
		goog.events.listen @rootElement_, goog.events.EventType.CLICK, @onClick

		#goog.events.listen @element_, goog.events.EventType.MOUSEDOWN, @onMouseDown
		goog.events.listen @, dm.ui.Table.EventType.CATCH, @onCaughtTable

		@clueTable = goog.dom.createDom 'div', 'table'
		goog.style.setStyle @clueTable, {
			opacity: 0.5, 'background-color': 'grey', width: 80, height: 100
			top: 0, left: 0, display: 'none'
		}

		@addTableInternal_ @clueTable

	###*
  * @param {string} canvasId Id of element to init canvas on
	###
	init: (canvasId) ->
		###
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
		###

	###*
  * @param {goog.events.Event} ev
  ###
	onDblClick: (ev) =>
		# clicked on empty place at canvase, where isnt any object 
		if ev.target is @rootElement_ then return false

		object = @getChild @getObjectIdByElement ev.target

		@dispatchEvent new dm.ui.Canvas.EditObject object

		###
		if table then @clickedTable table
		else if ev.target.nodeName is 'path' then @clickedRelation ev.target
		###

	###*
  * @param {goog.events.Event} ev
  ###
	onClick: (ev) =>
		if ev.target is @rootElement_ then object = null
		else object = @getChild @getObjectIdByElement ev.target
		
		position = goog.style.getRelativePosition ev, ev.currentTarget
		
		@dispatchEvent new dm.ui.Canvas.Click object, position

	###*
  * @param {goog.events.Event} ev
  * @param {goog.events.EventType=} endAction Action that stops moving
  ###
	onCaughtTable: (ev, endAction = goog.events.EventType.MOUSEUP) ->
		@move = object: ev.target, offset: ev.catchOffset
		goog.dom.classes.add @move.object, 'move'

		mouseMoveEvent = goog.events.EventType.MOUSEMOVE		

		goog.events.listen document, mouseMoveEvent, @moveTable
		
		goog.events.listenOnce document, endAction, =>
			goog.dom.classes.remove @move.object, 'move'
			@move = object: null, offset: null
			
			goog.events.unlisten document, mouseMoveEvent, @moveTable

	###*
  * @param {HTMLElement} table
 	###
	clickedTable: (table) ->
		#tid = table.id
		#tab = dm.actualModel.getTableById tid

		#dm.tableDialog.show tid
		#dm.tableDialog.setValues tab.getName(), tab.getColumnsArray()

	moveTable: (ev) =>
		offsetInCanvas = goog.style.getRelativePosition ev, @rootElement_
		
		#goog.style.showElement @clueTable.getElement(), true
		#@clueTable.setPosition position.x, position.y
		x = offsetInCanvas.x - @move.offset.x
		y = offsetInCanvas.y - @move.offset.y
		
		tabSize = if @move.object.getSize then @move.object.getSize() else goog.style.getSize @move.object 

		if x + tabSize.width > @size_.width then x = @size_.width - tabSize.width
		else if x < 0 then x = 0

		if y + tabSize.height > @size_.height then y = @size_.height - tabSize.height
		else if y < 0 then y = 0

		if @move.object.setPosition then @move.object.setPosition x, y else goog.style.setPosition @move.object, x, y
		
		@move.object.dispatchEvent dm.ui.Table.EventType.MOVE
		#console.log x, y

	###*
	* Save table element internaly and call function for render to DOM
  * @param {(dm.ui.Table)} table
	###	
	addTable: (table) =>
		@addChild table, false
		@addTableInternal_ table
		#id = dm.actualModel.addTable @html, tabPos.x, tabPos.y
		#goog.style.showElement @clueTable.getElement(), false

		#dm.tableDialog.setValues()
		#dm.tableDialog.show id

	###*
  * Add element to DOM
  * @param {(dm.ui.Table|Element)} table
	###
	addTableInternal_: (table) =>
		if table.render? then table.render @rootElement_
		else goog.dom.appendChild @rootElement_, table  

	###*
  * @param {(dm.ui.Relation)} relation
	###	
	addRelation: (relation) =>
		@addChild relation, false
		relation.draw canvas

	###*
	# @param {SVGPath} relation 
	###
	clickedRelation: (relation) ->
		#rid = relation.id
		#rel = dm.actualModel.getRelationById rid

		#dm.relationDialog.show rid
		#dm.relationDialog.setValues rel.startTab, rel.endTab, rel.isIdentifying()

	###*
  * @param {goog.math.Coordinate} startCoords
	###
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

		startTabName = dm.actualModel.getTableById startTab
		endTabName = dm.actualModel.getTableById endTab

		dm.relationDialog.setValues startTabName, endTabName
		dm.relationDialog.show id
	###
	###*
  * @param {Element} element
  * @return {string} 
	###
	getObjectIdByElement: (element) =>
		if element is @rootElement_ then return null 
		#else parent = goog.dom.getParentElement element 

		until element.id
			element = goog.dom.getParentElement element
		
		element.id 

goog.addSingletonGetter dm.ui.Canvas

class dm.ui.Canvas.EditObject extends goog.events.Event
	###*
  * @param {HTMLElement}
  * @constructor
  * @extends {goog.events.Event}
	###
	constructor: (obj) ->
		super dm.ui.Canvas.EventType.OBJECT_EDIT, obj

class dm.ui.Canvas.Click extends goog.events.Event
	###*
  * @param {(dm.ui.Table|dm.ui.Relation)}
  * @param {goog.math.Coordinate} position Position in canvas where was clicked
  * @constructor
  * @extends {goog.events.Event}
	###
	constructor: (obj, position) ->
		super dm.ui.Canvas.EventType.CLICK, obj

		@position = position
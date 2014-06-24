`/** @jsx React.DOM */`

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
    * @type {goog.math.Size}
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
		#goog.events.listen @, dm.ui.Table.EventType.CATCH, @onCaughtTable

		@clueTable = goog.dom.createDom 'div', 'table'
		goog.style.setStyle @clueTable, {
			opacity: 0.5, 'background-color': 'grey', width: 80, height: 100
			top: 0, left: 0, display: 'none'
		}

		@addTableInternal_ @clueTable

		[defs] = goog.dom.getElementsByTagNameAndClass 'defs', null, @getElement()
		defs.innerHTML = dm.ui.tmpls.CardinalityMarkers()

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
	* Save table element internaly and call function for render to DOM
  * @param {(dm.ui.Table)} table
	###	
	addTable: (table) =>
		@addChild table, false
		@addTableInternal_ table
		
		# update position of table if any part of table is outside the canvas 
		pos = table.getPosition()
		size = table.getSize()

		{width, height} = @getSize()

		x = if pos.x + size.width > width then width - size.width else pos.x
		y = if pos.y + size.height > height then height - size.height else pos.y

		if pos.x > x or pos.y > y then table.setPosition x, y 

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
		relation.draw this

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

	###*
  * @return {goog.math.Size}
	###
	getSize: ->
		@size_

	###*
	* Remove all objects (tables and relations) from canvas
	###
	clear: ->
		@removeChildren true

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
	constructor: (obj, @position) ->
		super dm.ui.Canvas.EventType.CLICK, obj

dm.ui.tmpls.CardinalityMarkers = ->
	markers = [
		dm.ui.tmpls.Cardinality(
			{id: 'oneExactly', width: 19, height: 19, refx: 0, refy: 10,
			path: 'M4,1 L4,18z M8,1 L8,18z'}
		)
		dm.ui.tmpls.Cardinality(
			{id: 'oneOptional', width: 39, height: 19, refx: 0, refy: 10,
			path: 'M4,1 l0,18z', circle:{x: 13, y:10 }}
		)
		dm.ui.tmpls.Cardinality(
			{id: 'oneOptionalEnd', width: 22, height: 19, refx: 21, refy: 10,
			path: 'M17,1 l0,18z', circle:{x: 8, y:10 }}
		)
		dm.ui.tmpls.Cardinality(
			{id: 'oneOrEn', width: 19, height: 19, refx: 0, refy: 10,
			path: 'M1,1 L14,10 L1,18 M14,1 L14,18z'}
		)
		dm.ui.tmpls.Cardinality(
			{id: 'oneOrEnEnd', width: 19, height: 19, refx: 21, refy: 10,
			path: 'M17,1 L4,10 L17,18 M3,1 L3,18z'}
		)
		dm.ui.tmpls.Cardinality(
			{id: 'oneOrEnOptional', width: 29, height: 19, refx: 0, refy: 10,
			path: 'M1,1 L14,10 L1,18', circle:{x: 21, y:10 }}
		)
		dm.ui.tmpls.Cardinality(
			{id: 'oneOrEnOptionalEnd', width: 32, height: 19, refx: 33, refy: 10,
			path: 'M29,1 L16,10 L29,18', circle:{x: 8, y:10 }}
		)
	]

	markers.join '\n'

dm.ui.tmpls.Cardinality = ({id, width, height, refx, refy, path, circle}) ->
	elements = ["<path d='#{path}' class='solidLine' />"]
	
	if circle?
		elements.push(
			"<circle cx='#{circle.x}' cy='#{circle.y}' r='7' class='solidLine' />"
		)

	"""
	<marker id='#{id}' markerWidth='#{width}'' markerHeight='#{height}'' refx='#{refx}'' refy='#{refy}'' orient='auto' markerUnits='userSpaceOnUse'>
		#{elements.join('\n')}
	</marker>
	"""
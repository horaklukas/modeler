goog.provide 'dm.model.Table'

goog.require 'tmpls.model'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.soy'
goog.require 'goog.style'
goog.require 'goog.math.Coordinate'
goog.require 'goog.math.Vec2'

class dm.model.Table
	constructor: (canvas, id, @x, @y, @w = 100, @h = 80) ->
		# if passed coordinates would caused that any part of table would be
		# outside canvas, recount coordinates
		canvSize = goog.style.getSize canvas
		
		if x + @w > canvSize.width then @x = canvSize.width - @w
		if y + @h > canvSize.height then @y = canvSize.height - @h

		# table's position coordinates
		@position = new goog.math.Coordinate @x, @y
		# table's list of related relations
		@relations = []

		#properties = width: @w, height: @h, left: x, top: y
		@table = goog.soy.renderAsElement tmpls.model.table, {'id': id}
		
		goog.style.setPosition @table, @x, @y
			
		goog.dom.appendChild canvas, @table

		goog.events.listen @table, goog.events.EventType.MOUSEDOWN, @graspTable

	###*
  * Callback that is called when user grasp table with intent to move it
	###
	graspTable: (ev) =>
		@startTable()

		pos = goog.style.getPosition @table
		@position = new goog.math.Coordinate pos.x, pos.y
		@offsetInTab = goog.style.getRelativePosition ev, @table

		goog.events.listen document, goog.events.EventType.MOUSEMOVE, @moveTable
		goog.events.listenOnce document, goog.events.EventType.MOUSEUP, @stopTable

	startTable: =>

	moveTable: (ev) =>
		goog.dom.classes.add @table, 'move'
		
		canvas = dm.ui.Canvas.getInstance().html
		canvasSize = goog.style.getSize canvas

		offsetInCanvas = goog.style.getRelativePosition ev, canvas

		@position = new goog.math.Coordinate(
			 offsetInCanvas.x - @offsetInTab.x,
			 offsetInCanvas.y - @offsetInTab.y
		)

		# Check moving table inside the borders
		if @position.x < 0 then @position.x = 0
		else if @position.x > canvasSize.width - @w
			@position.x = canvasSize.width - @w
		
		if @position.y < 0 then @position.y = 0
		else if @position.y > canvasSize.height - @h
			@position.y = canvasSize.height - @h

		# Check if relation connection point should be changed or left
		rel.recountPosition() for rel in @relations

		goog.style.setPosition @table, @position.x, @position.y

	stopTable: =>
		goog.dom.classes.remove @table, 'move'
		goog.events.unlisten document, goog.events.EventType.MOUSEMOVE, @moveTable

	###*
  * @return {Object.<string,goog.math.Coordinate>}
	###
	getConnPoints: ->
		top: new goog.math.Coordinate(@position.x + @w / 2, @position.y)
		right: new goog.math.Coordinate(@position.x + @w + 1, @position.y + @h / 2)
		bottom: new goog.math.Coordinate(@position.x + @w / 2, @position.y + @h + 1)
		left: new goog.math.Coordinate(@position.x, @position.y + @h / 2)

	addRelation: (rel) ->
		@relations.push rel

	setName: (@name) ->
		tableHead = goog.dom.getElementsByTagNameAndClass(null, 'head', @table)[0]
		goog.dom.setTextContent tableHead, name		

	getName: -> @name

	###*
	* Save table columns with all its attributes and render columns to table on
	* canvas
	*
	* @param {Object.<string,*>} columns Table columns with its attributes
	###
	setColumns: (@columns) ->
		tableBody = goog.dom.getElementsByTagNameAndClass(null, 'body', @table)[0]
		goog.soy.renderElement tableBody, tmpls.model.tabColumns, {cols: columns}

	getColumns: -> @columns		

if not window? then module.exports = Table
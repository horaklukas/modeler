goog.provide 'dm.ui.Relation'

goog.require 'dm.ui.Table.EventType'
goog.require 'goog.graphics.SvgGroupElement'
goog.require 'goog.graphics.SvgPathElement'
goog.require 'goog.graphics.Path'
goog.require 'goog.graphics.SolidFill'
goog.require 'goog.graphics.Stroke'
goog.require 'goog.ui.IdGenerator'

#idGen = goog.ui.IdGenerator.getInstance()

strokeBg = new goog.graphics.Stroke 10, 'transparent'
relationStroke = new goog.graphics.Stroke 2, '#000'

class dm.ui.Relation extends goog.ui.Component #goog.graphics.SvgGroupElement
	###*
  * @const
  * @static
	###
	@width = 2

	###*
	* @param {dm.model.Relation}
  * @param {dm.ui.Table}
  * @param {dm.ui.Table}
  * @constructor
	###
	constructor: (relationModel, parentTab, childTab) ->
		#super canvas

		###*
    * @type {string}
		###
		#@id_ = idGen.getNextUniqueId()

		###*
    * @type {dm.model.Relation}
		###
		@setModel relationModel

		###*
    * @type {dm.ui.Table}
		###
		@parentTab = parentTab

		###*
    * @type {dm.ui.Table}
		###
		@childTab = childTab

		###*
    * @type {goog.graphics.SvgPathElement}
		###
		@relationPath_ = null

	###*
  * @param {dm.ui.Canvas} canvas
	###
	###
	addTo: (canvas) ->
		path = @getRelationPath(new goog.graphics.Path)
		
		@relationBg_ = canvas.drawPath path, strokeBg
		@relationPath_ = canvas.drawPath path, relationStroke
		
		#@relationPath_.getElement().setAttribute 'id', @id_

		if @model_ then @setRelationType()

		goog.events.listen @parentTab, dm.ui.Table.EventType.MOVE, @recountPosition
		goog.events.listen @childTab, dm.ui.Table.EventType.MOVE, @recountPosition
	###	
	###*
  * @param {dm.ui.Canvas} canvas
	###
	draw: (canvas) ->
		path = @getRelationPath(new goog.graphics.Path)
		
		@relationGroup_ = canvas.createGroup()
		@relationBg_ = canvas.drawPath path, strokeBg, null, @relationGroup_
		@relationPath_ = canvas.drawPath path, relationStroke, null, @relationGroup_
		
		@relationGroup_.getElement().id = @getId()
		
		#@relationPath_.getElement().setAttribute 'id', @id_

		if @model_ then @setRelationType()

		goog.events.listen @parentTab, dm.ui.Table.EventType.MOVE, @recountPosition
		goog.events.listen @childTab, dm.ui.Table.EventType.MOVE, @recountPosition

	###*
  * @param {dm.model.Relation} model
	###
	setModel: (model) ->
		@model_ = model
		
		goog.events.listen @model_, 'type-change', @setRelationType

	recountPosition: =>
		@relationPath_.setPath @getRelationPath(new goog.graphics.Path)
		@relationBg_.setPath @getRelationPath(new goog.graphics.Path)

	###*
	* @param {goog.graphics.Path} path Path object to set points on
  * @return {goog.graphics.Path} new relation path
	###
	getRelationPath: (path) =>
		points = @getRelationPoints()
		
		#path.lineTo points.break1.x, points.break1.y
		
		#unless goog.math.Coordinate.equals points.break2, points.break1
		#	path.lineTo points.break2.x, points.break2.y
		
		###
		widthHalf = dm.ui.Relation.width / 2

		if points.start.edge in ['top', 'bottom'] 
			path.moveTo points.start.coords.x - widthHalf, points.start.coords.y
		else
			path.moveTo points.start.coords.x, points.start.coords.y - widthHalf
		
		if points.stop.edge in ['top', 'bottom']
			path.lineTo points.stop.coords.x - widthHalf, points.stop.coords.y
			path.lineTo points.stop.coords.x + widthHalf, points.stop.coords.y
		else
			path.lineTo points.stop.coords.x, points.stop.coords.y - widthHalf
			path.lineTo points.stop.coords.x, points.stop.coords.y + widthHalf

		if points.start.edge in ['top', 'bottom']
			path.lineTo points.start.coords.x + widthHalf, points.start.coords.y
		else
			path.lineTo points.start.coords.x, points.start.coords.y + widthHalf
		###
		path.moveTo points.start.coords.x, points.start.coords.y
		path.lineTo points.stop.coords.x, points.stop.coords.y

	###*
  * @return {Object.<string,goog.math.Coordinate>}
	###
	getRelationPoints: =>
		sTab = @getTableConnectionPoints @parentTab
		eTab = @getTableConnectionPoints @childTab
		dists = []
		distsPoint = []

		for sPos, sCoord of sTab
			for ePos, eCoord of eTab
				dist = @getPathDistance sPos, sCoord, ePos, eCoord

				if dist isnt false
					dists.push dist
					distsPoint[dist] = [sPos, ePos]

		if dists.length is 0 then result = ['top', 'top']
		else result = distsPoint[Math.min dists...]

		#start = sTab[result[0]]
		#stop = eTab[result[1]]
		#breaks = @getBreakPoints start, result[0], stop, result[1]

		#start: start, break1: breaks[0], break2: breaks[1],	stop: stop
		start: edge: result[0], coords: sTab[result[0]]
		stop: edge: result[1], coords: eTab[result[1]]

	###*
  *
  * @param {string} pos1 Name of first connection point (r = right, l = left, 
  *  t = top, b = bottom)
  * @param {goog.math.Coordinate} coord1
  * @param {string} pos2 Name of second connection point (r = right, l = left, 
  *  t = top, b = bottom)
  * @param {goog.math.Coordinate} coord2
  * @return {number|boolean} returns number of distance, if it's possible from
  * points position else return false
	###
	getPathDistance: (pos1, coord1, pos2, coord2) ->
		if pos1 is pos2 or
			(
				((pos1 isnt 'right' and pos2 isnt 'left') or coord1.x < coord2.x) and
				((pos1 isnt 'left' and pos2 isnt 'right') or coord1.x > coord2.x) and
				((pos1 isnt 'bottom' and pos2 isnt 'top') or coord1.y < coord2.y) and
				((pos1 isnt 'top' and pos2 isnt 'bottom') or coord1.y > coord2.y)
			)
				Math.abs(coord1.x - coord2.x) + Math.abs(coord1.y - coord2.y)
				#goog.math.Coordinate.distance coord1, coord2
		else
			false

	###*
  * @param {dm.ui.Table} table
  * @relation {Object.<string, goog.math.Coordinate>}
	###
	getTableConnectionPoints: (table) ->
		tableElement =  table.getElement()
		bounds = goog.style.getBounds tableElement
		bounds.top -= 31 # 29 size of toolbar 1 * 2 is border of table for both 
		bounds.left -= 2 # 1 * 2 is border of table for both 

		'top': new goog.math.Coordinate bounds.left + bounds.width / 2, bounds.top
		'right': new goog.math.Coordinate(
			bounds.left + bounds.width, bounds.top + bounds.height / 2
		)
		'left': new goog.math.Coordinate(
			bounds.left, bounds.top + bounds.height / 2
		)
		'bottom': new goog.math.Coordinate(
			bounds.left + bounds.width / 2, bounds.top + bounds.height
		)

	###*
  *
  * @param {goog.math.Coordinate} start Relation start point coordinates
  * @param {string} sPos Position of start relation point
  * @param {goog.math.Coordinate} end Relation end point coordinates
  * @param {string} ePos Position of end relation point
  * @return {Array.<goog.math.Coordinate>} Two relation break points
	###
	###
	getBreakPoints: (start, sPos, end, ePos) ->
		horiz = ['left','right']
		vert = ['top', 'bottom']

		# if connection points are in same direction, there are two break points
		# otherwise there is only one break point
		if sPos in horiz and ePos in horiz
			x = ((end.x - start.x) / 2) + start.x

			b1 = new goog.math.Coordinate x, start.y
			b2 = new goog.math.Coordinate x, end.y
		else if sPos in vert and ePos in vert
			y = ((end.y - start.y) / 2) + start.y

			b1 = new goog.math.Coordinate start.x, y
			b2 = new goog.math.Coordinate end.x, y
		else
			if sPos is 'right' or sPos is 'left'
				b1 = b2 = new goog.math.Coordinate end.x, start.y
			if ePos is 'right' or ePos is 'left'
				b1 = b2 = new goog.math.Coordinate start.x, end.y

		console.log sPos, ePos, b1, b2

		[b1, b2]
	###	

	###*
	* Changes relation stroke typ by identifying
	###
	setRelationType: ->
		identify = @model_.isIdentifying()
		relationElement = @relationPath_.getElement()
		
		if identify then relationElement.removeAttribute 'stroke-dasharray'
		else relationElement.setAttribute 'stroke-dasharray', '10 5'
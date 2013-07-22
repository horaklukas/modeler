goog.provide 'dm.model.Relation'

goog.require 'goog.math.Coordinate'
goog.require 'goog.graphics.Path'
goog.require 'goog.graphics.Stroke'

class dm.model.Relation
	###*
  * @constructor
	###
	constructor: (canvas, @startTab, @endTab, type) ->
		stroke = new goog.graphics.Stroke 1, '#000'
		@obj = canvas.drawPath @getPathPosition(), stroke

	recountPosition: ->
		@obj.setPath @getPathPosition()

	###*
  * @return {goog.graphics.Path} new path that represents the relation
	###
	getPathPosition: =>
		points = @getRelationPoints()
		path = new goog.graphics.Path()
		
		path.moveTo points.start.x, points.start.y
		path.lineTo points.break1.x, points.break1.y
		
		unless goog.math.Coordinate.equals points.break2, points.break1
			path.lineTo points.break2.x, points.break2.y
		
		path.lineTo points.stop.x, points.stop.y

	###*
  * @return {Object.<string,goog.math.Coordinate>}
	###
	getRelationPoints: =>
		sTab = @startTab.getConnPoints()
		eTab = @endTab.getConnPoints()
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

		start = sTab[result[0]]
		stop = eTab[result[1]]
		breaks = @getBreakPoints start, result[0], stop, result[1]

		start: start, break1: breaks[0], break2: breaks[1],	stop: stop

	###*
  *
  * @param {string} pos1
  * @param {goog.math.Coordinate} coord1
  * @param {string} pos2
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
  *
  * @param {goog.math.Coordinate} start Relation start point coordinates
  * @param {string} sPos Position of start relation point
  * @param {goog.math.Coordinate} end Relation end point coordinates
  * @param {string} ePos Position of end relation point
  * @return {Array.<goog.math.Coordinate>} Two relation break points
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

if not window? then module.exports = Relation
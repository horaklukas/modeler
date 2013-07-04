goog.provide 'dm.components.model.Relation'

class dm.components.model.Relation
	constructor: (canvas, @startTab, @endTab, type) ->
		@obj = canvas.path()
		@recountPosition()

	recountPosition: =>
		points = @getRelationPoints()

		path = "M#{points.start.x},#{points.start.y}"+
			"L#{points.break1.x},#{points.break1.y}"+
			"L#{points.break2.x},#{points.break2.y}"+
			"L#{points.stop.x},#{points.stop.y}"
		
		@obj.attr 'path', path

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

		start: x: start.x, y: start.y
		break1: x: breaks[0].x, y: breaks[0].y
		break2: x: breaks[1].x, y: breaks[1].y
		stop: x: stop.x, y: stop.y

	###*
  *
  * @param {string} pos1
  * @param {Object.<string,number>} coord1
  * @param {string} pos2
  * @param {Object.<string,number>} coord2
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
		else
			false

	###*
  *
  * @param {Object.<string,number>} start Relation start point coordinates
  * @param {string} sPos Position of start relation point
  * @param {Object.<string,number>} end Relation end point coordinates
  * @param {string} ePos Position of end relation point
  * @return {Object.<string,Object>} Two relation break points
	###
	getBreakPoints: (start, sPos, end, ePos) ->
		horiz = ['left','right']
		vert = ['top', 'bottom']
		b1 = x: null, y: null
		b2 = x: null, y: null

		if sPos in horiz and ePos in horiz
      b1.x = b2.x = ((end.x - start.x) / 2) + start.x
      b1.y = start.y
      b2.y = end.y
   	else if sPos in vert and ePos in vert
      b1.y = b2.y = ((end.y - start.y) / 2) + start.y
      b1.x = start.x
      b2.x = end.x
  	else
      b1.x = b2.x = end.x
      b1.y = b2.y = start.y

    [b1, b2]				

if not window? then module.exports = Relation
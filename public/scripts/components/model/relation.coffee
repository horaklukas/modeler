class Relation
	constructor: (canvas, @startTab, @endTab, type) ->
		@obj = canvas.path()
		@recountPosition()

	recountPosition: =>
		ends = @getEndPointsCoords()
		path = "M#{ends.start.x},#{ends.start.y}L#{ends.stop.x},#{ends.stop.y}"
		
		@obj.attr 'path', path

	getEndPointsCoords: =>
		sTab = @startTab.getConnPoints()
		eTab = @endTab.getConnPoints()
		dists = []
		distsPoint = []

		for sPos, sCoord of sTab
			for ePos, eCoord of eTab

				if((sPos is ePos) or
					(
						((sPos isnt 'right' and ePos isnt 'left') or sCoord.x < eCoord.x) or
						((sPos isnt 'left' and ePos isnt 'right') or sCoord.x > eCoord.x) or
						((sPos isnt 'bottom' and ePos isnt 'top') or sCoord.y < eCoord.y) or 
						((sPos isnt 'top' and ePos isnt 'bottom') or sCoord.y > eCoord.y)
					))
						dist = Math.abs(sCoord.x - eCoord.x) + Math.abs(sCoord.y - eCoord.y)
						dists.push dist
						distsPoint[dist] = [sPos, ePos]

		if dists.length is 0 then result = ['top', 'top']
		else result = distsPoint[Math.min dists...]

		start: x: sTab[result[0]].x, y: sTab[result[0]].y
		stop: x: eTab[result[1]].x, y: eTab[result[1]].y

if not window? then module.exports = Relation
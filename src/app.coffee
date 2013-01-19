

###
w = $('modelerCanvas').width()
h = $('modelerCanvas').height()
modelerCanvas = Raphael "modelerCanvas", w, h

x = 0
y = 0
newEntity = false

templateTable = modelerCanvas.rect [0, 0, 100, 60, 2]...
templateTable.attr {fill:'#CCC', opacity: 0.5}
templateTable.hide()

moveTable = (dx, dy) ->
	@attr { x: x + dx, y: y + dy } 

startTable = ->
	x = @attr 'x'
	y = @attr 'y'
	@attr 'opacity', 0.5

endTable = ->
	@attr 'opacity', 1

$('#modelerCanvas').on {
		'click' : (e) -> 
			if newEntity is true
				tableAttrs = [e.offsetX, e.offsetY, 100, 60, 2]
				table = modelerCanvas.rect tableAttrs...
				table.attr {fill:'#EEE', stroke: '#000', opacity: 1}
				table.drag moveTable, startTable, endTable
				templateTable.hide()
				$('#controlPanel [name=newTable]').trigger 'tableCreated'				

		'mousemove' : (e) ->
			if newEntity is true
				templateTable.show()
				templateTable.attr { x: e.offsetX, y: e.offsetY }
}, 'svg'

$('#controlPanel').on {
		'click' : -> 
			newEntity = true
			$(this).addClass 'active'
		'tableCreated' : ->
			newEntity = false
			$(thi).removeClass 'active'

	}, '[name=newTable]'

$(document).on {
		'mouseup' : (ev) -> 
			newEntity = false
}
###
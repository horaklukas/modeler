class Table
	position: 
		relative: x: null, y: null
		absolute: x: null, y: null

	constructor: (canvas, id, @x, @y, @w = 100, @h = 80) ->
		properties = width: @w, height: @h, left: @x, top: @y
		@table = $('<div class="table"><input class="head" ></div>').css(properties).attr 'id', id
			
		@table.appendTo canvas#Canvas.obj
		canvasMax =
			maxX: canvas.width?() or $(canvas).width()
			maxY: canvas.height?() or $(canvas).height()


		@table.on 'mousedown', (ev) =>
			@startTable ev
			$(document).on 'mousemove', canvasMax, @moveTable
			$(document).one 'mouseup', =>
				$(document).off 'mousemove', @moveTable
				@stopTable() 	

	startTable: (ev) =>
		position = @table.position()
		@position.relative = x: position.left, y: position.top
		@position.absolute = x: ev.pageX, y: ev.pageY
		
		#console.log 'start', @start.x, @start.y

	moveTable: (ev) =>
		@table.addClass 'move'
		
		xDiff = ev.pageX - @position.absolute.x
		yDiff = ev.pageY - @position.absolute.y
		
		newX = @position.relative.x + xDiff
		newY = @position.relative.y + yDiff
		
		# Check moving table inside the borders
		if newX < 0 then newX = 0
		else if newX > ev.data.maxX - @w then newX = ev.data.maxX - @w
		
		if newY < 0 then newY = 0
		else if newY > ev.data.maxY - @h then newY = ev.data.maxY - @h

		@table.css 'left': newX, 'top': newY

	stopTable: =>
		@table.removeClass 'move'

	###createAnchors: (canvas) ->
		lt = @table.head.attr ['x','y']
		rb = 
			x: @table.body.attr('x') + @table.body.attr('width')
			y: @table.body.attr('y') + @table.body.attr('height')

		for side in ['t','l','b','r']
			@anchors[side] = new Anchor canvas, side, lt, rb	
	###

	show: ->	@table.all.show()

	hide: -> @table.all.hide()

if not window? then module.exports = Table
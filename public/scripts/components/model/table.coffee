class Table
	constructor: (canvas, id, @x, @y, @w = 100, @h = 80) ->
		# coordinates of canvas's right bottom corner
		canvasMax =
			maxX: canvas.width?() or $(canvas).width()
			maxY: canvas.height?() or $(canvas).height()

		# if passed coordinates would caused that any part of table would be
		# outside canvas, recount coordinates
		if x + @w > canvasMax.maxX then @x = canvasMax.maxX - @w
		if y + @h > canvasMax.maxY then @y = canvasMax.maxY - @h

		# table's position coordinates
		@position =
			current: x: @x, y: @y
			startmove: 
				relative: x: @x, y: @y
				absolute: x: null, y: null

		# table's list of related relations
		@relations = []	

		#properties = width: @w, height: @h, left: x, top: y
		properties = left: @x, top: @y
		@table = jQuery tmpls.components.model.table 'id': id
		@table.css properties 
			
		@table.appendTo canvas

		@table.on 'mousedown', canvasMax, @graspTable

	###*
  * Callback that is called when user grasp table with intent to move it
	###
	graspTable: (ev) =>
		canvasMax = ev.data

		@startTable ev
		$(document).on 'mousemove', canvasMax, @moveTable
		$(document).one 'mouseup', =>
			$(document).off 'mousemove', @moveTable
			@stopTable() 	

	startTable: (ev) =>
		{left, top} = @table.position()

		@position.current = x: left, y: top
		@position.startmove.relative = x: left, y: top
		@position.startmove.absolute = x: ev.pageX, y: ev.pageY

	moveTable: (ev) =>
		@table.addClass 'move'
		
		# Position difference from position where moving began
		xDiff = ev.pageX - @position.startmove.absolute.x
		yDiff = ev.pageY - @position.startmove.absolute.y
		
		@position.current.x = @position.startmove.relative.x + xDiff
		@position.current.y = @position.startmove.relative.y + yDiff
		
		# Check moving table inside the borders
		if @position.current.x < 0 then @position.current.x = 0
		else if @position.current.x > ev.data.maxX - @w
			@position.current.x = ev.data.maxX - @w
		
		if @position.current.y < 0 then @position.current.y = 0
		else if @position.current.y > ev.data.maxY - @h
			@position.current.y = ev.data.maxY - @h

		# Check if relation connection point should be changed or left
		rel.recountPosition() for rel in @relations

		@table.css 'left': @position.current.x, 'top': @position.current.y

	stopTable: =>
		@table.removeClass 'move'

	getConnPoints: ->
		top: x: @position.current.x + @w / 2, y: @position.current.y
		right: x: @position.current.x + @w + 1, y: @position.current.y + @h / 2
		bottom: x: @position.current.x + @w / 2, y: @position.current.y + @h + 1
		left: x: @position.current.x, y: @position.current.y + @h / 2

	addRelation: (rel) ->
		@relations.push rel

	setName: (@name) ->
		$('.head', @table).text @name

	getName: -> @name

	setColumns: (@columns) ->
		$('.body', @table).html tmpls.components.model.tabColumns cols: columns

	getColumns: -> @columns		

if not window? then module.exports = Table
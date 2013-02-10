class Table
	start: x: [], y: []

	constructor: (canvas, @x, @y, @w = 100, @h = 60) ->
		#@anchors = {}
		@table = {}

		@table.all = canvas.set()
		@table.head = canvas.rect(@x, @y, @w, 20, 2).attr {fill:'#AAA', stroke: '#000', opacity: 1}
		@table.body = canvas.rect(@x, @y + 19, @w, @h, 2).attr {fill:'#EEE', stroke: '#000', opacity: 1}
		@table.all.push @table.head, @table.body
		#@initAnchors canvas

		#@table.body.drag @moveTable, @startTable, @endTable
		@table.all.drag @moveTable, @startTable, @endTable

	startTable: =>
		@start.x = []
		@start.y = []

		for part in @table.all 
			@start.x.push part.attr 'x' 
			@start.y.push part.attr 'y'
			console.log 'start', part, @start.x, @start.y	

		#anch.start = anch.obj.attr ['x','y'] for k, anch of @anchors	

		@table.all.attr 'opacity': 0.5, 'cursor': 'move'

	moveTable: (dx, dy) =>
		console.log 'move ',dx, dy

		for part, i in @table.all
			#console.log @start.x[i] + dx, @start.y[i] + dy
			@table.all[i].attr { x: @start.x[i] + dx, y: @start.y[i] + dy }

		#for k, anch of @anchors
		#	anch.obj.attr { x: anch.start.x + dx , y: anch.start.y + dy}	

	endTable: =>
		@table.all.attr 'cursor', 'default'
		@table.all.attr 'opacity', 1

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
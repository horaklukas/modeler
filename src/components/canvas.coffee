class Canvas
	constructor: (id) ->
		@object = $ "##{id}"
		@object.addClass 'canvas'
		@w = @object.witdh()
		@h = @object.height()


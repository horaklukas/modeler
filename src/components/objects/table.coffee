class Table
	constructor: (canvas, @x, @y, @w = 80, @h = 60) ->
		@obj = canvas.rect @x, @y, @w, @h, 2

	show: ->	@obj.show()

	hide: -> @obj.hide()

if module then module.exports = Table
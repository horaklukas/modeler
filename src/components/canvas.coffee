###*
* @module
###
Canvas =
	###*
  * 
  * @param {jQueryObject} id Id of element to init canvas on
  * @param {Function} cb Callback to be invoked when init is finished
	###
	init: (canvasObj, cb) ->
		@obj = canvasObj
		@witdh = canvasObj.width()
		@height = canvasObj.height()

		@self = Raphael @obj.attr('id'), @witdh, @height

		if cb then cb()

	on: (event, target, cb) -> @obj.on event, target, cb

	off: (event, target, cb) ->	@obj.off event, target, cb	
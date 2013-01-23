###*
* @module
###
ControlPanel =
	obj: null
	activeTool: null
	clueTable: null

	###*
  * @param {jQueryObject} obj Control panel element selected by jQuery
  * @param {Function} cb Callback to be invoked after init finished
  ###
	init: (obj, cb) ->
		@obj = obj
		@obj.on 'click', '.tool', @toolActivated 

		if cb then cb()

	toolActivated: (ev) ->
		$tool = $(@)
		toolName = $tool.attr('name')

		$tool.addClass 'active'

		ControlPanel.activeTool = toolName

		ev.stopImmediatePropagation()
		# Init tool
		ControlPanel["#{toolName}Init"]() 

	toolFinished: (ev)->
		ControlPanel["#{ControlPanel.activeTool}Finish"]() 
		$('.active', @obj).removeClass 'active'

		@activeTool = null

	createTableInit: ->
		if not @clueTable?
			@clueTable = Canvas.self.rect 0, 0, 100, 80, 2 
			@clueTable.attr(fill:'#CCC', opacity: 0.5).hide()

		# When moving over canvas, show blind table as clue
		Canvas.on 'mousemove', (ev) ->
			ControlPanel.clueTable.show().attr 'x': ev.offsetX, 'y': ev.offsetY

		# When click on canvas create new table and finish tool action
		Canvas.on 'click', (ev) -> 
			ControlPanel.clueTable.hide()
			new Table Canvas.self, ev.offsetX, ev.offsetY, 100, 60
			ControlPanel.toolFinished() 
		
		$(document).on 'click', @toolFinished

	createTableFinish: () ->
		# Deactivate all events
		Canvas.off 'mousemove', @moveClueTable
		Canvas.off 'click',  @create
		$(document).off 'click', @toolFinished

	createRelationshipInit: () ->

	createRelationshipFinish: () ->	
		

if not window? then module.exports = ControlPanel		
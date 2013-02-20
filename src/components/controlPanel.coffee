###*
* @module
###
ControlPanel =
	obj: null
	activeTool: null
	clueTable: null
	clueRelation: null
	relStart: x: null, y: null

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

		if $tool.hasClass 'active' then ControlPanel.toolFinished()
		else
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
		unless @clueTable?
			@clueTable = Canvas.self.rect 0, 0, 100, 80, 2 
			@clueTable.attr(fill:'#CCC', opacity: 0.5).hide()

		# When moving over canvas, show blind table as clue
		Canvas.on 'mousemove', (ev) ->
			ControlPanel.clueTable.show().attr 'x': ev.offsetX, 'y': ev.offsetY

		# When click on canvas create new table and finish tool action
		Canvas.on 'click', (ev) -> 
			ControlPanel.clueTable.hide()
			App.actualModel.addTable Canvas.obj, ev.offsetX, ev.offsetY
			ControlPanel.toolFinished() 
		
		$(document).on 'click', @toolFinished

	createTableFinish: () ->
		# Deactivate all events
		Canvas.off 'mousemove'
		Canvas.off 'click'
		$(document).off 'click', @toolFinished

	createRelationInit: (ev) ->
		Canvas.css 'cursor': 'crosshair'

		Canvas.on 'click', (ev) ->
			if not ControlPanel.relStart.x? and not ControlPanel.relStart.y?
				pos = ControlPanel.relStart = 'x': ev.offsetX, 'y': ev.offsetY

				startPath = "M#{pos.x} #{pos.y}"
				ControlPanel.clueRelation = Canvas.self.path "M#{pos.x} #{pos.y}"

				Canvas.on 'mousemove', (ev) ->
					ControlPanel.clueRelation.attr 'path', "#{startPath}L#{ev.offsetX} #{ev.offsetY}"
			else
				ControlPanel.toolFinished()	

	createRelationFinish: () ->
		Canvas.css 'cursor': 'default'
		Canvas.off 'mousemove'
		Canvas.off 'click'
		@relStart = x: null, y: null

if not window? then module.exports = ControlPanel		
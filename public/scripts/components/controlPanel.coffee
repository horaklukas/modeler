###*
* @module
###
ControlPanel =
	obj: null
	activeTool: null
	clueTable: null
	clueRelation: null
	relStart: x: null, y: null, id: null

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
			id = App.actualModel.addTable Canvas.obj, ev.offsetX, ev.offsetY
			ControlPanel.toolFinished() 
			App.dialogs.createTable.show id
			App.dialogs.createTable.onConfirm App.actualModel.editTable
		
		$(document).on 'click', @toolFinished

	createTableFinish: () ->
		ControlPanel.clueTable.hide()

		# Deactivate all events
		Canvas.off 'mousemove'
		Canvas.off 'click'
		$(document).off 'click', @toolFinished

	createRelationInit: (ev) ->
		Canvas.css 'cursor': 'crosshair'
		canvasPos = Canvas.obj.position()

		Canvas.on 'click', '.table', (ev) ->
			unless ControlPanel.relStart.x? and ControlPanel.relStart.y?
				pos = ControlPanel.relStart = 
					'x': ev.clientX - canvasPos.left, 'y': ev.clientY - canvasPos.top
				startPath = "M#{pos.x} #{pos.y}"
				ControlPanel.relStart.id = @.id	

				# Create clue relation or only set start point to existing
				unless ControlPanel.clueRelation?
					ControlPanel.clueRelation = Canvas.self.path startPath
				else
					ControlPanel.clueRelation.attr('path', startPath).show()

				# When moving over canvas, change end point of relation	
				Canvas.on 'mousemove', (ev) ->
					ControlPanel.clueRelation.attr 'path', "#{startPath}L#{ev.clientX - canvasPos.left} #{ev.clientY-canvasPos.top}"
			else
				App.actualModel.addRelation Canvas.self, ControlPanel.relStart.id, @.id
				ControlPanel.toolFinished()	

	createRelationFinish: () ->
		ControlPanel.clueRelation.hide()

		Canvas.css 'cursor': 'default'
		Canvas.off 'mousemove'
		Canvas.off 'click', '.table'
		@relStart = x: null, y: null

if not window? then module.exports = ControlPanel		
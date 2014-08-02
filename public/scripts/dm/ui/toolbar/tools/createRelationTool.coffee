goog.provide 'dm.ui.tools.CreateRelation'

goog.require 'dm.ui.tools.CreateToggleButton'
goog.require 'dm.ui.Canvas'
goog.require 'dm.ui.tools.ObjectCreateEvent'
goog.require 'goog.style'
goog.require 'goog.events'
goog.require 'goog.dom.classes'

class dm.ui.tools.CreateRelation extends dm.ui.tools.CreateToggleButton
	###*
	* @param {boolean} ident If button creates identifying relation or not
  * @constructor
  * @extends {dm.ui.tools.CreateToggleButton}
	###
	constructor: (ident = true) ->
		###*
    * @type {boolean}
		###
		@ident = ident

		clss = 'rel-ident'
		title = 'Create identifying relationship'

		if ident is false
			clss = clss.replace 'ident', 'non-ident'
			title = title.replace 'ident', 'non-ident'			

		super clss, title

		###*
    * @type {dm.ui.Table}
		###
		@parentTable = null

		###*
    * @type {dm.ui.Table}
		###
		@childTable = null

	startAction: ->
		canvas = dm.ui.Canvas.getInstance()
		#goog.style.setStyle canvas.getElement(), 'cursor', 'pointer'
		#canvas..style.cursor = 'pointer'

	###*
  * @param {dm.ui.Canvas.Click} ev Click on canvas event
	###
	setActionEvent: (ev) ->
		obj = ev.target
		if obj instanceof dm.ui.Table
			goog.dom.classes.add obj.getElement(), 'active'

			if not @parentTable? then @parentTable = obj
			else if not @childTable then @childTable = obj; return true

		return false

	###*
  * @param {?goog.math.Coordinate} position
  * @param {?HTMLElement} object
	###
	finishAction: (position, object) =>
		# if creating relation canceled with other action before select both tables
		# do not dispatch event, only unmark `active`

		unless @parentTable then return false
		else goog.dom.classes.remove @parentTable.getElement(), 'active'

		unless @childTable then @parentTable = null; return false
		
		goog.dom.classes.remove @childTable.getElement(), 'active'
		
		@dispatchEvent new dm.ui.tools.ObjectCreateEvent(
			'relation', {
				parent: @parentTable.getId()
				child: @childTable.getId()
				identifying: @ident
			}
		)

		@parentTable = null
		@childTable = null

	cancel: ->
		if @parentTable?
			goog.dom.classes.remove @parentTable.getElement(), 'active'

		@parentTable = null
		@childTable = null
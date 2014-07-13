goog.provide 'dm.ui.Relation'

goog.require 'dm.ui.Table.EventType'
goog.require 'dm.model.Table.index'
goog.require 'goog.graphics.Path'
goog.require 'goog.graphics.Stroke'
goog.require 'goog.object'
goog.require 'goog.dom'
goog.require 'dm.ui.tmpls.createElementFromReactComponent'

class dm.ui.Relation extends goog.ui.Component
	###*
  * @const
  * @static
	###
	@relationStroke: new goog.graphics.Stroke 2, '#000'
	
	###*
  * @const
  * @static
	###
	@strokeBg: new goog.graphics.Stroke 10, 'transparent'

	###*
	* @param {dm.model.Relation}
  * @constructor
	###
	constructor: (relationModel) ->
		super()

		@setModel relationModel

		###*
    * @type {goog.graphics.SvgPathElement}
		###
		@relationPath_ = null

	###*
  * @param {dm.ui.Canvas} canvas
	###
	draw: (canvas) ->
		model = @getModel()
		parentTable = canvas.getChild model.tables.parent
		childTable = canvas.getChild model.tables.child

		parentModel = parentTable.getModel()
		childModel = childTable.getModel()
		
		path = @getRelationPath(
			new goog.graphics.Path
			parentTable.getElement()
			childTable.getElement()
		)
		
		@relationGroup_ = canvas.createGroup()
		@relationBg_ = canvas.drawPath(
			path, dm.ui.Relation.strokeBg, null, @relationGroup_
		)
		@relationPath_ = canvas.drawPath(
			path, dm.ui.Relation.relationStroke, null, @relationGroup_
		)

		@setCardinalityMarkers model.getCardinalityParciality()
		
		groupElement = @relationGroup_.getElement()
		groupElement.id = @getId()
		
		#if @getModel()? then @setRelationType()

		@setRelationType model.isIdentifying()
		@setRelatedTablesKeys parentModel, childModel

		# highlight background of relation when mouse move over
		goog.events.listen groupElement, goog.events.EventType.MOUSEOVER, ->
			@firstChild.setAttribute 'stroke', '#ccc'
		goog.events.listen groupElement, goog.events.EventType.MOUSEOUT, ->
			@firstChild.setAttribute 'stroke', 'transparent'

		@setElementInternal groupElement

	###*
  * Recount new position of relation endpoints and set it
  *
  * @param {Element} parentTable
  * @param {Element} childTable
	###
	recountPosition: (parentTable, childTable) =>
		newPath = @getRelationPath new goog.graphics.Path, parentTable, childTable
		
		@setCardinalityMarkers @getModel().getCardinalityParciality()

		@relationPath_.setPath newPath
		@relationBg_.setPath newPath

	setCardinalityMarkers: ({cardinality, parciality})->
		parentClassName = @getCardinalityClass cardinality.parent, parciality.parent
		childClassName = @getCardinalityClass cardinality.child, parciality.child, true

		goog.style.setStyle @relationPath_.getElement(), {
			markerStart: "url(##{parentClassName})" 
			markerEnd: "url(##{childClassName})" 
		}

	###*
  * Handler for `changed relation type` event
  *
  * @param {!dm.model.Table} childTabModel
	###
	onTypeChange: (childTabModel) =>
		relationModel = @getModel()

		mapping = relationModel.getColumnsMapping()
		isIdentifying = relationModel.isIdentifying()

		@setRelationType isIdentifying

		for map in mapping
			childTabModel.setIndex(
				map.child, dm.model.Table.index.PK, not isIdentifying
			)

	###*
  * @param {Object.<string,string>} cardinality
  * @param {Object.<string,number>} parciality
  * @param {boolean=} end
  * @return {string} class name
	###
	getCardinalityClass: (cardinality, parciality, end = false) ->
		className = 'one'

		if cardinality is 'n' then className += 'OrEn'

		if parciality is 1 and cardinality is '1' then className += 'Exactly'
		else if parciality is 0 then className += 'Optional'

		if end is true then className += 'End'

		className

	###*
  * @param {goog.graphics.Path} path Path object to set points on
  * @param {Element} parentTable
  * @param {Element} childTable
  * @return {goog.graphics.Path} new relation path
	###
	getRelationPath: (path, parentTable, childTable) =>
		{start, stop} = @getRelationPoints parentTable, childTable
		
		#path.lineTo points.break1.x, points.break1.y
		#unless goog.math.Coordinate.equals points.break2, points.break1
		#	path.lineTo points.break2.x, points.break2.y
		
		###
		widthHalf = dm.ui.Relation.width / 2

		if points.start.edge in ['top', 'bottom'] 
			path.moveTo points.start.coords.x - widthHalf, points.start.coords.y
		else
			path.moveTo points.start.coords.x, points.start.coords.y - widthHalf
		
		if points.stop.edge in ['top', 'bottom']
			path.lineTo points.stop.coords.x - widthHalf, points.stop.coords.y
			path.lineTo points.stop.coords.x + widthHalf, points.stop.coords.y
		else
			path.lineTo points.stop.coords.x, points.stop.coords.y - widthHalf
			path.lineTo points.stop.coords.x, points.stop.coords.y + widthHalf

		if points.start.edge in ['top', 'bottom']
			path.lineTo points.start.coords.x + widthHalf, points.start.coords.y
		else
			path.lineTo points.start.coords.x, points.start.coords.y + widthHalf
		###
		path.moveTo start.coords.x, start.coords.y

		# unary relation cant be straight
		if parentTable is childTable
			path.lineTo start.coords.x - 40, start.coords.y
			path.lineTo start.coords.x - 40, stop.coords.y + 40
			path.lineTo stop.coords.x, stop.coords.y + 40
		
		path.lineTo stop.coords.x, stop.coords.y

	###*
  * @param {Element} parentTable
  * @param {Element} childTable
  * @return {Object.<string,goog.math.Coordinate>}
	###
	getRelationPoints: (parentTable, childTable) =>
		model = @getModel()
		sTab = @getTableConnectionPoints parentTable
		eTab = @getTableConnectionPoints childTable
		dists = []
		distsPoint = []


		for sPos, sCoord of sTab
			for ePos, eCoord of eTab
				dist = @getPathDistance sPos, sCoord, ePos, eCoord

				if dist isnt false
					dists.push dist
					distsPoint[dist] = [sPos, ePos]

		if parentTable is childTable then result = ['left', 'bottom']
		else if dists.length is 0 then result = ['top', 'top']
		else result = distsPoint[Math.min dists...]

		#start = sTab[result[0]]
		#stop = eTab[result[1]]
		#breaks = @getBreakPoints start, result[0], stop, result[1]

		#start: start, break1: breaks[0], break2: breaks[1],	stop: stop
		start: edge: result[0], coords: sTab[result[0]]
		stop: edge: result[1], coords: eTab[result[1]]

	###*
  *
  * @param {string} pos1 Name of first connection point (r = right, l = left, 
  *  t = top, b = bottom)
  * @param {goog.math.Coordinate} coord1
  * @param {string} pos2 Name of second connection point (r = right, l = left, 
  *  t = top, b = bottom)
  * @param {goog.math.Coordinate} coord2
  * @return {number|boolean} returns number of distance, if it's possible from
  * points position else return false
	###
	getPathDistance: (pos1, coord1, pos2, coord2) ->
		if pos1 is pos2 or
			(
				((pos1 isnt 'right' and pos2 isnt 'left') or coord1.x < coord2.x) and
				((pos1 isnt 'left' and pos2 isnt 'right') or coord1.x > coord2.x) and
				((pos1 isnt 'bottom' and pos2 isnt 'top') or coord1.y < coord2.y) and
				((pos1 isnt 'top' and pos2 isnt 'bottom') or coord1.y > coord2.y)
			)
				Math.abs(coord1.x - coord2.x) + Math.abs(coord1.y - coord2.y)
				#goog.math.Coordinate.distance coord1, coord2
		else
			false

	###*
  * @param {Element} tableElement
  * @relation {Object.<string, goog.math.Coordinate>}
	###
	getTableConnectionPoints: (tableElement) ->
		bounds = goog.style.getBounds tableElement
		bounds.top -= 31 # 29 size of toolbar 1 * 2 is border of table for both 
		bounds.left -= 2 # 1 * 2 is border of table for both 

		'top': new goog.math.Coordinate bounds.left + bounds.width / 2, bounds.top
		'right': new goog.math.Coordinate(
			bounds.left + bounds.width, bounds.top + bounds.height / 2
		)
		'left': new goog.math.Coordinate(
			bounds.left, bounds.top + bounds.height / 2
		)
		'bottom': new goog.math.Coordinate(
			bounds.left + bounds.width / 2, bounds.top + bounds.height
		)

	###*
  *
  * @param {goog.math.Coordinate} start Relation start point coordinates
  * @param {string} sPos Position of start relation point
  * @param {goog.math.Coordinate} end Relation end point coordinates
  * @param {string} ePos Position of end relation point
  * @return {Array.<goog.math.Coordinate>} Two relation break points
	###
	###
	getBreakPoints: (start, sPos, end, ePos) ->
		horiz = ['left','right']
		vert = ['top', 'bottom']

		# if connection points are in same direction, there are two break points
		# otherwise there is only one break point
		if sPos in horiz and ePos in horiz
			x = ((end.x - start.x) / 2) + start.x

			b1 = new goog.math.Coordinate x, start.y
			b2 = new goog.math.Coordinate x, end.y
		else if sPos in vert and ePos in vert
			y = ((end.y - start.y) / 2) + start.y

			b1 = new goog.math.Coordinate start.x, y
			b2 = new goog.math.Coordinate end.x, y
		else
			if sPos is 'right' or sPos is 'left'
				b1 = b2 = new goog.math.Coordinate end.x, start.y
			if ePos is 'right' or ePos is 'left'
				b1 = b2 = new goog.math.Coordinate start.x, end.y

		console.log sPos, ePos, b1, b2

		[b1, b2]
	###	

	###*
	* Changes relation stroke typ by identifying
	*
	* @param {boolean} identify
	###
	setRelationType: (identify) =>
		relationElement = @relationPath_.getElement()
		
		if identify then relationElement.removeAttribute 'stroke-dasharray'
		else relationElement.setAttribute 'stroke-dasharray', '10 5'

	###*
  * @param {dm.ui.Table} parent
  * @param {dm.ui.Table} child
	###
	###
	setRelatedTables: (parent, child) ->
		if @childTab?
			tableModel = @childTab.getModel()
			# remove columns of old child table created by relation
			ids = @getModel().getFkColumnsIds()
			goog.array.forEachRight ids, (id) -> tableModel.removeColumn id

		@parentTab = parent
		@childTab = child
		parentModel = parent.getModel()
		childModel = child.getModel()

		goog.events.listen parentModel, 'name-change', @setTablesNamesToModel
		goog.events.listen childModel, 'name-change', @setTablesNamesToModel

		@setTablesNamesToModel()
		@setRelatedTablesKeys()
		
		columnsListChangeEvents = ['column-add', 'column-delete']
		goog.events.listen parentModel, columnsListChangeEvents, @recountPosition
		goog.events.listen childModel, columnsListChangeEvents, @recountPosition
	###

	###*
  * Updates names of relation related tables if tables names change, used at
  * method `setRelatedTables` above
	###
	###
	setTablesNamesToModel: =>
		@getModel().setRelatedTables(
			@parentTab.getModel().getName(), @childTab.getModel().getName()
		)
	###

	###*
  * Adds foreign keys columns to child table and add primary index to it, if
  * relation is identifying
  *
  * @param {dm.model.Table} parentModel
  * @param {dm.model.Table} childModel
	###
	setRelatedTablesKeys: (parentModel, childModel) =>
		relationModel = @getModel()
		keysMapping = []

		parentCols = parentModel.getColumns()
		parentPkColIds = parentModel.getColumnsIdsByIndex dm.model.Table.index.PK
		isIdentifying = relationModel.isIdentifying()

		for pkColId in parentPkColIds
			childId = @addForeignKeyColumn(
				parentCols[pkColId], childModel, isIdentifying
			)

			keysMapping.push parent: pkColId, child: childId

		relationModel.setColumnsMapping keysMapping

	###*
  * @param {dm.ui.TableColumn} parentColumn
  * @param {dm.model.Table} childModel
  * @param {boolean} is Pk Determine if column should also have primary
  * @return {string} id of new column
	###
	addForeignKeyColumn: (parentColumn, childModel, isPk = false) ->
		childTableColumn = goog.object.clone parentColumn

		indexes = [dm.model.Table.index.FK]
		if isPk is true then goog.array.insert indexes, dm.model.Table.index.PK 

		id = childModel.setColumn childTableColumn, null, indexes 		

		return id

	removeRelatedTablesKeys: (childModel) =>
		relationModel = @getModel()
		isIdentifying = relationModel.isIdentifying()
		
		mapping = relationModel.getColumnsMapping()

		# remove indexes from columns created by relation, but columns left in table
		for mapp in mapping
			childModel.setIndex mapp.child, dm.model.Table.index.FK, true
			if isIdentifying
				childModel.setIndex mapp.child, dm.model.Table.index.PK, true

	disposeInternal: ->
		goog.events.removeAll @relationGroup_
		goog.dom.removeNode @relationGroup_.getElement()
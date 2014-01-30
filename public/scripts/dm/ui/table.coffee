goog.provide 'dm.ui.Table'
goog.provide 'dm.ui.Table.EventType'

goog.require 'tmpls.model'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.soy'
goog.require 'goog.style'
goog.require 'goog.math.Coordinate'
goog.require 'goog.math.Size'
goog.require 'goog.ui.Component'
goog.require 'goog.events'
goog.require 'goog.events.Event'
goog.require 'goog.fx.Dragger'

class dm.ui.Table extends goog.ui.Component
	@EventType =
		CATCH: goog.events.getUniqueId 'table-catch'	
		MOVE: goog.events.getUniqueId 'table-move'

	###*
  * @param {dm.model.Table} tableModel
  * @param {number=} x Coordinate on x axis
  * @param {number=} y Coordinate on y axis
  * @constructor
  * @extends {goog.ui.Component}
	###
	constructor: (tableModel, x = 0, y = 0) ->
		super()

		###* 
    * table's list of related relations
    * @type {Array.<dm.model.Relation>}
    ###
		#@relations_ = []

		#@size_ = new goog.math.Size w, h
		###*
    * @type {goog.math.Coordinate}
		###
		@position_ = new goog.math.Coordinate x, y

		###*
    * @type {Element}
		###
		@head_ = null
		
		###*
    * @type {Element}
		###
		@body_ = null

		###*
    * @type {goog.fx.Dragger}
		###
		@dragger = null

		@setModel tableModel

	###*
  * @override
	###
	createDom: =>
		model = @getModel()
		element = goog.soy.renderAsElement tmpls.model.table, {
			'id': @getId(), 'name': model.getName(), 'columns': model.getColumns()
		}
		
		@head_ = goog.dom.getElementByClass 'head', element
		@body_ = goog.dom.getElementByClass 'body', element

		@setElementInternal element

	###*
  * @override
	###
	enterDocument: ->
		super()
		goog.style.setPosition @element_, @position_.x, @position_.y
		
		@dragger = new goog.fx.Dragger @element_, @element_, @getDragLimits()

		dragStartEnd = (e) ->
			#@target.style.zIndex = if e.type is 'start' then 99 else 1
			@target.style.cursor = if e.type is 'start' then 'move' else 'default'
			goog.style.setOpacity @target, if e.type is 'start' then 0.7 else 1

		goog.events.listen @dragger, 'start', dragStartEnd 
		goog.events.listen @dragger, 'end', dragStartEnd

		#goog.events.listen @element_, goog.events.EventType.MOUSEDOWN, @graspTable

	###*
  * @override
	###
	setModel: (model) ->
		super model

		goog.events.listen model, 'name-change', (ev) => 
			@setName ev.target.getName()
		
		goog.events.listen model, 'column-change', (ev) =>
			@updateColumn ev.column.index, ev.column.data
		
		goog.events.listen model, 'column-add', (ev) =>
			@addColumn ev.column.data
			@dragger.setLimits @getDragLimits()
		
		goog.events.listen model, 'column-delete', (ev) =>
			@removeColumn ev.column.index
			@dragger.setLimits @getDragLimits()

	###*
  * @param {number} x
  * @param {number} y
	###
	setPosition: (x, y) =>
		# table's position coordinates and size dimensions
		@position_.x = x
		@position_.y = y

		if @isInDocument()
			goog.style.setPosition @element_, @position_.x, @position_.y

  ###*
  * @return {goog.math.Coordinate}
  ###
	getPosition: ->
		@position_

	###*
  * @return {goog.math.Rect}
	###
	getDragLimits: ->
		csz = dm.ui.Canvas.getInstance().getSize()
		tsz = @getSize() 
		
		new goog.math.Rect 0, 0, csz.width - tsz.width - 4, csz.height - tsz.height - 4

	###*
  * @return {Object.<string,goog.math.Coordinate>}
	###
	getConnPoints: ->
		top: new goog.math.Coordinate(@position_.x + @size_.width / 2, @position_.y)
		right: new goog.math.Coordinate(@position_.x + @size_.width + 1, @position_.y + @size_.height / 2)
		bottom: new goog.math.Coordinate(@position_.x + @size_.width / 2, @position_.y + @size_.height + 1)
		left: new goog.math.Coordinate(@position_.x, @position_.y + @size_.height / 2)

	###*
  * @return {goog.math.Size} table dimensions
	###
	getSize: ->
		goog.style.getSize @element_

	###*
	* @param {dm.model.Relation}
	###
	###
	addRelation: (rel, child = false) ->
		@relations_.push rel
	###
	###*
  * @param {string} name Name of table
	###
	setName: (name = '') ->		
		goog.dom.setTextContent @head_, name		

	###*
	* Adds new columns or updates existing
	* @param {Array.<(Object,<string,*>|dm.model.TableColumn)>} columns List of
	*  table columns at keys based object
	###
	###
	setColumns: (columns) ->
		@setColumn column for column in columns 
	###

	###*
  * @param {dm.model.TableColumn} column
	###
	addColumn: (column) ->
		@body_.innerHTML += tmpls.model.tabColumn col: column

	###*
	* @param {number} index
	* @param {dm.model.TableColumn} newColumn
	###
	updateColumn: (index, column) ->
		oldColumn = goog.dom.getElementsByClass('column', @body_)[index]
		newColumn = goog.soy.renderAsElement tmpls.model.tabColumn, col: column

		goog.dom.replaceNode newColumn, oldColumn

	###*
  * @param {number} index
	###
	removeColumn: (index) ->
		column = goog.dom.getElementsByClass('column', @body_)[index]
		goog.dom.removeNode column
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
		goog.events.listen @element_, goog.events.EventType.MOUSEDOWN, @graspTable

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
		goog.events.listen model, 'column-delete', (ev) =>
			@removeColumn ev.column.index

	###*
  * @param {number} x
  * @param {number} y
	###
	setPosition: (x, y) =>
		# if passed coordinates would caused that any part of table would be
		# outside canvas, recount coordinates
		###canvasSize = goog.style.getSize @getCanvas()

		if x + @size_.w > canvasSize.width then x = canvasSize.width - @size_.w
		else if x < 0 then x = 0

		if y + @size_.h > canvasSize.height then y = canvasSize.height - @size_.h
		else if y < 0 then y = 0
		###
	
		# table's position coordinates and size dimensions
		@position_.x = x
		@position_.y = y

		if @isInDocument()
			goog.style.setPosition @element_, @position_.x, @position_.y

	###*
  * Callback that is called when user grasp table with intent to move it
  * @param {goog.events.Event} ev
	###
	graspTable: (ev) =>
		unless @position_.x? or not @position_.y?
			pos = goog.style.getPosition @element_
			@position_.x = pos.x
			@position_.y = pos.y

		offsetInTab = goog.style.getRelativePosition ev, @element_
		@dispatchEvent new dm.ui.Table.TableCatch offsetInTab

		#goog.events.listen document, goog.events.EventType.MOUSEMOVE, @moveTable
		#goog.events.listenOnce document, goog.events.EventType.MOUSEUP, @stopTable

	###*
  * @param {goog.events.Event} ev
  ###
	moveTable: (ev) =>
		#goog.dom.classes.add @element_, 'move'

		#offsetInCanvas = goog.style.getRelativePosition ev, @getCanvas()
		
		#x = offsetInCanvas.x - @offsetInTab.x
		#y = offsetInCanvas.y - @offsetInTab.y

		#@setPosition x, y

		#rel.recountPosition() for rel in @relations_

	stopTable: =>
		#goog.dom.classes.remove @element_, 'move'
		#goog.events.unlisten document, goog.events.EventType.MOUSEMOVE, @moveTable

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

		
class dm.ui.Table.TableCatch extends goog.events.Event
	###*
  * @param {goog.math.Coordinate} tabOffset
	###
	constructor: (tabOffset) ->
		super dm.ui.Table.EventType.CATCH

		###*
    * @type {goog.math.Coordinate}
		###
		@catchOffset = tabOffset
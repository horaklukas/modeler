goog.provide 'dm.model.Table'

goog.require 'tmpls.model'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.soy'
goog.require 'goog.style'
goog.require 'goog.math.Coordinate'
goog.require 'goog.math.Size'

class dm.model.Table
	constructor: (canvas, id, x, y, w = 100, h = 80) ->
		###* @type {dm.ui.Canvas} ###
		@parentCanvas_ = canvas

		###* @type {string}	###
		@id_ = id
		
		###* 
    * table's list of columns
    * @type {Array.<dm.model.TableColumn>}
    ###
		@columns_ = []
		
		#@fkeys = []

		###* 
    * table's list of related relations
    * @type {Array.<dm.model.Relation>}
    ###
		@relations_ = []

		@name_ = null

		@size_ = new goog.math.Size w, h
		@position_ = null

		@element_ = goog.soy.renderAsElement tmpls.model.table, 'id': id
		goog.dom.appendChild @parentCanvas_, @element_

		@setPosition x, y

		goog.events.listen @element_, goog.events.EventType.MOUSEDOWN, @graspTable

	###*
  * @param {dm.ui.Canvas} canvas
  * @param {number} x
  * @param {number} y
	###
	setPosition: (x, y) =>
		# if passed coordinates would caused that any part of table would be
		# outside canvas, recount coordinates
		canvasSize = goog.style.getSize @getCanvas()

		if x + @size_.w > canvasSize.width then x = canvasSize.width - @size_.w
		else if x < 0 then x = 0

		if y + @size_.h > canvasSize.height then y = canvasSize.height - @size_.h
		else if y < 0 then y = 0

		# table's position coordinates and size dimensions
		@position_ = new goog.math.Coordinate x, y

		goog.style.setPosition @element_, x, y

	###*
  * Callback that is called when user grasp table with intent to move it
  * @param {goog.events.Event} ev
	###
	graspTable: (ev) =>
		pos = goog.style.getPosition @element_
		@position_ = new goog.math.Coordinate pos.x, pos.y
		@offsetInTab = goog.style.getRelativePosition ev, @element_

		goog.events.listen document, goog.events.EventType.MOUSEMOVE, @moveTable
		goog.events.listenOnce document, goog.events.EventType.MOUSEUP, @stopTable

	###*
  * @param {goog.events.Event} ev
  ###
	moveTable: (ev) =>
		goog.dom.classes.add @element_, 'move'

		offsetInCanvas = goog.style.getRelativePosition ev, @getCanvas()
		
		x = offsetInCanvas.x - @offsetInTab.x
		y = offsetInCanvas.y - @offsetInTab.y

		@setPosition x, y

		rel.recountPosition() for rel in @relations_

	stopTable: =>
		goog.dom.classes.remove @element_, 'move'
		goog.events.unlisten document, goog.events.EventType.MOUSEMOVE, @moveTable

	###*
  * @return {Object.<string,goog.math.Coordinate>}
	###
	getConnPoints: ->
		top: new goog.math.Coordinate(@position_.x + @size_.width / 2, @position_.y)
		right: new goog.math.Coordinate(@position_.x + @size_.width + 1, @position_.y + @size_.height / 2)
		bottom: new goog.math.Coordinate(@position_.x + @size_.width / 2, @position_.y + @size_.height + 1)
		left: new goog.math.Coordinate(@position_.x, @position_.y + @size_.height / 2)

	###*
	* @param {dm.model.Relation}
	###
	addRelation: (rel, child = false) ->
		@relations_.push rel

	###*
  * @param {string} name
	###
	setName: (name = '') ->
		@name_ = name
		
		tableHead = goog.dom.getElementByClass 'head', @element_
		goog.dom.setTextContent tableHead, name		

	###*
  * @return {string}
	###
	getName: ->
		@name_

	###*
	* Render (or rerender) table columns and recount table size
	###
	render: ->
		tableBody = goog.dom.getElementByClass 'body', @element_
		goog.soy.renderElement tableBody, tmpls.model.tabColumns, {cols: @columns_}

		@size_ = goog.style.getSize @element_

	###*
	* @param {Array.<Object>} columns List of columns with its attributes
	* @param {boolean} rewrite Determine if columns should rewrite existing,
	* instead of append column(s)
	###
	addColumns: (columns, rewrite = false) ->
		if rewrite is true then @columns_ = []

		@columns_ = @columns_.concat columns

	###*
	* @param {dm.model.TableColumn} newColumn
	* @param {boolean} isFk Wheather column is foreign key, default is false
	###
	addColumn: (newColumn, isFk = false) ->
		@columns_.push newColumn

		#if isFk then @fkeys.push newColumn.name

	getColumns: ->
		@columns_

	###*
	* @return {dm.ui.Canvas}
	###
	getCanvas: ->
		@parentCanvas_

if not window? then module.exports = Table
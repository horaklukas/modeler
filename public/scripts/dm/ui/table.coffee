`/** @jsx React.DOM */`

goog.provide 'dm.ui.Table'
goog.provide 'dm.ui.Table.EventType'
goog.provide 'dm.ui.tmpls'

goog.require 'goog.dom'
goog.require 'goog.dom.query'
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
		element = dm.ui.tmpls.createElementFromReactComponent dm.ui.tmpls.Table(
			{id: @getId(), name: model.getName(), columns: model.getColumns()}
		)
		
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
		
		goog.events.listen @dragger, 'drag', => 
			@dispatchEvent dm.ui.Table.EventType.MOVE
		
		goog.events.listen @dragger, 'end', dragStartEnd

	###*
  * @override
	###
	setModel: (model) ->
		super model

		goog.events.listen model, 'name-change', (ev) => 
			@setName ev.target.getName()
		
		goog.events.listen model, 'column-change', (ev) =>
			@updateColumn ev.column.id, ev.column.data
		
		goog.events.listen model, 'column-add', (ev) =>
			@addColumn ev.column.id, ev.column.data
			@dragger.setLimits @getDragLimits()
		
		goog.events.listen model, 'column-delete', (ev) =>
			@removeColumn ev.column.id
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
  * @param {string} id
  * @param {dm.model.TableColumn} column
	###
	addColumn: (id, column) ->
		@body_.innerHTML += React.renderComponentToStaticMarkup(
			dm.ui.tmpls.Column {id: id, data: column}
		)

	###*
	* @param {string} id
	* @param {dm.model.TableColumn} newColumn
	###
	updateColumn: (id, column) ->
		oldColumn = goog.dom.query("[name=#{id}]", @body_)[0]
		newColumn = dm.ui.tmpls.createElementFromReactComponent(
			dm.ui.tmpls.Column {id: id, data: column}
		)

		goog.dom.replaceNode newColumn, oldColumn

	###*
  * @param {string} id
	###
	removeColumn: (id) ->
		column = goog.dom.query("[name=#{id}]", @body_)[0]
		goog.dom.removeNode column


dm.ui.tmpls.createElementFromReactComponent = (reactComponent) ->
	componentHtml = React.renderComponentToStaticMarkup reactComponent
	wrapper = goog.dom.createElement 'div'

	wrapper.innerHTML = componentHtml

	goog.dom.getFirstElementChild wrapper


# Table templates
dm.ui.tmpls.Table = React.createClass
	render: ->
		{TableColumns} = dm.ui.tmpls

		`(
		<div className="table" id={this.props.id}>
			<span className="head">{this.props.name}</span>
			<TableColumns cols={this.props.columns} />
		</div>
		)`

dm.ui.tmpls.TableColumns = React.createClass
	render: ->
		{Column} = dm.ui.tmpls
		columns = []
		
		goog.object.forEach @props.cols, (data, id) ->
			columns.push `( <Column id={id} data={data} key={id} /> )`

		`( <div className="body">{columns}</div> )`

dm.ui.tmpls.Column = React.createClass
	createIndex: (index) ->
		`( <span className="idx" key={index} >{index}</span> )`


	render: ->
		{id, data} = @props
		indexes = goog.array.map (data.indexes ? []), @createIndex

		`(
		<div className="column" name={id}>
			<span>{data.name}</span>
			{indexes}				
		</div>
		)`


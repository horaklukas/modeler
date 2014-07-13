`/** @jsx React.DOM */`

goog.provide 'dm.ui.RelationDialog'

###
goog.require 'goog.ui.Dialog'
goog.require 'goog.ui.Dialog.ButtonSet'
#goog.require 'tmpls.dialogs.createRelation'
goog.require 'goog.dom'
#goog.require 'goog.soy'
goog.require 'goog.events'
###

goog.require 'goog.array'
goog.require 'goog.string'
goog.require 'dm.ui.Dialog'

dm.ui.RelationDialog = React.createClass
  _originalModel: null

  ###*
  * @param {dm.model.Relation} model
  * @param {Object.<string, object>} tables Info about relation related tables
  ###
  show: (model, tables) ->
    @_originalModel = model

    #@tablesSwaped = false
    #parentName = relation.parentTab.getModel().getName()
    #childName = relation.childTab.getModel().getName()
    
    @setProps {
      parentName: tables.parent.name
      childName: tables.child.name
    }

    {cardinality, parciality} = model.getCardinalityParciality()

    @setState 
      visible: true
      name: model.getName()
      identifying: model.isIdentifying()
      cardinality: cardinality
      parciality: parciality

  onConfirm: ->
    @_originalModel.setType @state.identifying
    @_originalModel.setCardinalityParciality(
      @state.cardinality, @state.parciality
    )
    @_originalModel.setName @state.name

    @hide()

  hide: ->
    @setState visible: false

  handleTypeChange: (isIdentifying) ->
    @setState identifying: isIdentifying

  handleCardModChange: (cardinality, parciality) ->
    nextState = {}
    if cardinality? then nextState.cardinality = cardinality
    if parciality? then nextState.parciality = parciality

    @setState nextState

  handleNameChange: ({target}) ->
    @setState name: target.value

  getInitialState: ->
    visible: false
    name: ''
    identifying: false
    cardinality: parent: '1', child: 'n'
    parciality: parent: 1, child: 1

  render: ->
    {Dialog} = dm.ui
 
    title = "Relation \"#{this.state.name}\""
    {visible, identifying, cardinality, parciality} = @state

    `(
    <Dialog title={title} onConfirm={this.onConfirm} onCancel={this.hide}
      visible={visible}>
      
      <p>
        Relation name
        <input value={this.state.name} onChange={this.handleNameChange} />
      </p>

      <p>Parent table: <strong>{this.props.parentName}</strong></p>
      <p>Child table: <strong>{this.props.childName}</strong></p>

      <RelationTypeSelect identifying={identifying} 
        onChange={this.handleTypeChange} />
      <CardinalityModalitySelect identifying={identifying} parciality={parciality} 
        cardinality={cardinality} onChange={this.handleCardModChange} />
    </Dialog>
    )`

RelationTypeSelect = React.createClass
  handleChange: (e) ->    
    @props.onChange !!goog.string.toNumber(e.target.value)

  createType: (type, idx) ->
    selected = if @props.identifying then 1 else 0
    checked = idx is selected

    `(
      <div key={idx}>
        <input type="radio" className="type" checked={checked} value={idx}
          onChange={this.handleChange} />
        {type} relation
      </div>
    )`

  render: ->
    options = goog.array.map ['Non-Identifying', 'Identifying'], @createType

    `( <div><p><strong>Relation type</strong></p>{options}</div> )`

CardinalityModalitySelect = React.createClass
  handleCardinalityChange: (type, ev) ->
    {cardinality} = @props
    cardinality[type] = ev.target.value

    @props.onChange cardinality, null

  handleModalityChange: (type, ev) ->
    {parciality} = @props
    parciality[type] = goog.string.toNumber ev.target.value

    @props.onChange null, parciality

  createCardinality: (card, type, disabled = false) ->
    cb = goog.partial @handleCardinalityChange, type
    
    `(
      <div>
        <div>
          <input type="radio" value="1" checked={card == '1'} onChange={cb}
            disabled={disabled} />
          One exactly
        </div>
        <div>
          <input type="radio" value="n" checked={card == 'n'} onChange={cb}
            disabled={disabled} />
          One or more
        </div>
      </div>
    )`

  createModality: (moda, type, disabled = false) ->
    cb = goog.partial @handleModalityChange, type

    `(
      <div>
        <div>
          <input type="radio" value="1" checked={moda == 1} onChange={cb}
            disabled={disabled} />
          Mandatory
        </div>
        <div>
          <input type="radio" value="0" checked={moda == 0} onChange={cb}
            disabled={disabled} />
          Optional
        </div>
      </div>
    )`

  render: ->
    {cardinality, parciality, identifying} = @props

    `(
      <div className="cardmod">
        <strong>Parent</strong>
        <div className="row">
          {this.createCardinality(cardinality.parent, 'parent')}
          {this.createModality(parciality.parent, 'parent', identifying)}
        </div>
        <strong>Child</strong>
        <div className="row">
          {this.createCardinality(cardinality.child, 'child')}
          {this.createModality(parciality.child, 'child')}
        </div>
      </div>
    )`

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

{Dialog} = dm.ui

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

    @setState 
      visible: true
      identifying: model.isIdentifying()

  onConfirm: ->
    @_originalModel.setType @state.identifying

  hide: ->
    @setState 
      visible: false

  handleTypeChange: (isIdentifying) ->
    @setState identifying: isIdentifying

  getInitialState: ->
    visible: false
    identifying: false

  render: ->
    title = "Relation between tables \"#{@props.parentName}\" and \"#{@props.childName}\""
    show = @state.visible

    `(
    <Dialog title={title} onConfirm={this.onConfirm} visible={show}>
      <RelationTypeSelect identifying={this.state.identifying} 
        onChange={this.handleTypeChange} />
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

    `( <div><div>Relation type</div>{options}</div> )`

`/*
class dm.dialogs.RelationDialog extends goog.ui.Dialog
  @EventType =
    CONFIRM: goog.events.getUniqueId 'dialog-confirmed'

  constructor: ->
    super()
    
    @isIdentifying = false
    @tablesSwaped = false

    #@relatedTables = parent: null, child: null

    @setContent tmpls.dialogs.createRelation.dialog false
    @setButtonSet goog.ui.Dialog.ButtonSet.createOkCancel()
    @setDraggable false

    # force render dialog, so all control widgets exists since now
    content = @getContentElement()
    
    @relPrefsForm = goog.dom.getElement 'relprefs'

    # events 1) change identifying of relation 2) dialog ok or cancel
    goog.events.listen @relPrefsForm, goog.events.EventType.CHANGE, @setIdentifying

    goog.events.listen @relPrefsForm, goog.events.EventType.SUBMIT, @swapTables

    goog.events.listen @, goog.ui.Dialog.EventType.SELECT, @onSelect

  ###*
  * If change type of relation (identifying or non-identifying) then save
  * actual value 
  * @param {goog.events.Event} ev
  ###
  setIdentifying: (ev) =>
    @isIdentifying = Boolean goog.string.toNumber ev.target.value

  ###*
  * @param {goog.events.Event} ev
  ###
  swapTables: (ev) =>
    # swap ids
    @tablesSwaped = !@tablesSwaped

    # swap tables names in dialog
    parent = goog.dom.getElementByClass 'parent', ev.target
    child = goog.dom.getElementByClass 'child', ev.target

    tmp = goog.dom.getTextContent parent

    goog.dom.setTextContent parent, goog.dom.getTextContent child
    goog.dom.setTextContent child, tmp

    ev.preventDefault()

  ###*
  * @param {boolean} show Wheater show or hide dialog
  * @param {dm.ui.Relation=} relation
  ###
  show: (show, relation) ->
    if relation?
      @relatedRelation = relation
      @isIdentifying = relation.getModel().isIdentifying()
      @tablesSwaped = false
      parentName = relation.parentTab.getModel().getName()
      childName = relation.childTab.getModel().getName()

      @setValues parentName,  childName, @isIdentifying
      @setTitle "Relation between tables \"#{parentName}\" and \"#{childName}\""

    @setVisible show 

  onSelect: (e) =>
    if e.key isnt 'ok' then return true
    
    @relatedRelation.getModel().setType @isIdentifying
    
    if @tablesSwaped then @relatedRelation.setRelatedTables(
      @relatedRelation.childTab, @relatedRelation.parentTab
    )
      #tmp = @relatedRelation.parentTab
      #@relatedRelation.parentTab = @relatedRelation.childTab
      #@relatedRelation.childTab = tmp
    #confirmEvent =  new dm.dialogs.RelationDialog.Confirm(@, @relatedRelation, @isIdentifying, @relatedTables.parent, @relatedTables.child)

    #@dispatchEvent confirmEvent

  ###*
  * @param {string} parent Parent table name
  * @param {string} child Child table name
  * @param {boolean} ident 
  ###
  setValues: (parent, child, ident) ->
    #@isIdentifying = ident
    #@relatedTables.parent = dm.actualModel.getTableById parent.getId()
    #@relatedTables.child = dm.actualModel.getTableById child.getId()

    goog.soy.renderElement @relPrefsForm, tmpls.dialogs.createRelation.prefs, 
      { ident: ident, parentTable: parent, childTable: child }

goog.addSingletonGetter dm.dialogs.RelationDialog

#class dm.dialogs.RelationDialog.Confirm extends goog.events.Event
# constructor: (dialog, id, ident, parenttab, childtab) ->
#   super dm.dialogs.RelationDialog.EventType.CONFIRM, dialog


###*
* @type {string}
###
#@relationId = id

###*
* @type {boolean}
###
#@identifying = ident

###*
* @type {string}
###
#@parentTable = parenttab

###*
* @type {string}
###
#@childTable = childtab
*/`
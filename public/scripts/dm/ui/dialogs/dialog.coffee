`/** @jsx React.DOM */`

goog.provide 'dm.ui.Dialog'

goog.require 'goog.dom'
goog.require 'goog.style'

dm.ui.Dialog = React.createClass
  statics:
    buttonSet:
      OK: 'ok'
      CANCEL: 'cancel'
      OK_CANCEL: 'okcancel'
      SELECT: 'select'
      NONE: 'none'

  cancelDialog: ->
    @setState visible: false

  confirmDialog: ->
    hide = if @props.onConfirm? then @props.onConfirm() else true
    
    # dont hide dialog when confirm callback return false, it lets option for
    # deffer hide of dialog
    unless hide is false then @setState visible: false

  getButtons: ->
    buttons = ''

    switch @props.buttons
      when dm.ui.Dialog.buttonSet.OK
        buttons = `( 
          <button type="button" onClick={this.confirmDialog}>Ok</button> 
        )`

      when dm.ui.Dialog.buttonSet.CANCEL
        buttons = `( 
          <button type="button" onClick={this.cancelDialog}>Cancel</button> 
        )`
            
      when dm.ui.Dialog.buttonSet.OK_CANCEL
        buttons = [
          `( <button key="okBtn" type="button" onClick={this.confirmDialog}>Ok</button> )`
          `( <button key="cancelBtn" type="button" onClick={this.cancelDialog}>Cancel</button> )`
        ]

      when dm.ui.Dialog.buttonSet.SELECT
        buttons = `( 
          <button type="button" onClick={this.confirmDialog}>Select</button> 
        )`

      when dm.ui.Dialog.buttonSet.NONE
        return ''
    
    `( <div className="buttons">{buttons}</div> )`

  componentWillReceiveProps: (props) ->
    if props.visible? then @setState visible: props.visible

  componentDidUpdate: (prevProps, prevState) ->
    if prevState.visible is true or @state.visible is false then return

    dialogElement = goog.dom.getElementByClass 'dialog', @getDOMNode()
    dialogSize = goog.style.getSize dialogElement
    viewSize = goog.dom.getViewportSize()

    @setState 
      top: (viewSize.height / 2) - (dialogSize.height / 2)
      left: (viewSize.width / 2) - (dialogSize.width / 2)

  getInitialState: ->
    visible: false
    top: 0
    left: 0

  getDefaultProps: ->
    title: ''
    buttons: dm.ui.Dialog.buttonSet.OK_CANCEL

  render: ->
    containerStyles =
      display: if @state.visible then 'block' else 'none'

    dialogStyles = 
      top: @state.top
      left: @state.left

    `(
    <div className="dialog-container" style={containerStyles} >
      <div className="bg" />
      <div className="dialog" style={dialogStyles}>
        <div className="title">{this.props.title}</div>
        <div className="content">
          {this.props.children}
        </div>
        {this.getButtons()}
      </div>
    </div>
    )`
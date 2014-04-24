`/** @jsx React.DOM */`

goog.provide 'dm.ui.Dialog'

goog.require 'goog.dom'

dm.ui.Dialog = React.createClass
  statics:
    buttonSet:
      OK: 'ok'
      OK_CANCEL: 'okcancel'
      SELECT: 'select'

  cancelDialog: ->
    @setState visible: false

  confirmDialog: ->
    hide = @props.onConfirm()
    
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
            
      when dm.ui.Dialog.buttonSet.OK_CANCEL
        buttons = [
          `( <button key="okBtn" type="button" onClick={this.confirmDialog}>Ok</button> )`
          `( <button key="cancelBtn" type="button" onClick={this.cancelDialog}>Cancel</button> )`
        ]

      when dm.ui.Dialog.buttonSet.SELECT
        buttons = `( 
          <button type="button" onClick={this.confirmDialog}>Select</button> 
        )`
    
    `( <div className="buttons">{buttons}</div> )`

  componentWillReceiveProps: (props) ->
    if props.visible? then @setState visible: props.visible

  getInitialState: ->
    visible: false

  getDefaultProps: ->
    title: ''
    buttons: dm.ui.Dialog.buttonSet.OK_CANCEL

  render: ->
    containerStyles =
      display: if @state.visible then 'block' else 'none'

    viewSize = goog.dom.getViewportSize()
    w = Math.max(viewSize.width, document.body.scrollWidth)
    h = Math.max(viewSize.height, document.body.scrollHeight)

    bgStyles = width: w, height: h

    dialogStyles = left: 153, top: 60

    `(
    <div className="dialog-container" style={containerStyles} >
      <div className="bg" style={bgStyles} />
      <div className="dialog" style={dialogStyles}>
        <div className="title">{this.props.title}</div>
        <div className="content">
          {this.props.children}
        </div>
        {this.getButtons()}
      </div>
    </div>
    )`
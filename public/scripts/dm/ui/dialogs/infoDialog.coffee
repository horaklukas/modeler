`/** @jsx React.DOM */`

goog.provide 'dm.ui.InfoDialog'

goog.require 'dm.ui.Dialog'
goog.require 'goog.string'

dm.ui.InfoDialog = React.createClass
  type:
    INFO: 'info'
    WARN: 'warning' 

  show: (info, type = dm.ui.InfoDialog.type.INFO) ->
    @setState visible: true, text: info, type: type

  hide: ->
    @setState visible: false

  getInitialState: ->
    visible: false
    value: ''
    type: dm.ui.InfoDialog.type.INFO

  render: ->
    {Dialog} = dm.ui
    {type} = @state
    buttonSet = dm.ui.Dialog.buttonSet.OK
    title = goog.string.toTitleCase type

    content = switch type
      when dm.ui.InfoDialog.type.INFO then 'i'
      when dm.ui.InfoDialog.type.WARN then '!'

    `(
      <Dialog className="info-dialog" title={title} buttons={buttonSet} 
        visible={this.state.visible} onConfirm={this.hide} onCancel={this.hide}
      >
        <p>
          <span className="icon {type}">{content}</span>
          {this.state.text}
        </p>
      </Dialog>
    )`

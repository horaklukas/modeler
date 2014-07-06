`/** @jsx React.DOM */`

goog.provide 'dm.ui.InfoDialog'

goog.require 'dm.ui.Dialog'
goog.require 'goog.string'

dm.ui.InfoDialog = React.createClass
  statics:
    types:
      INFO: 'info'
      WARN: 'warning' 

  show: (info, type = dm.ui.InfoDialog.types.INFO) ->
    @setState visible: true, text: info, type: type

  hide: ->
    @setState visible: false

  getInitialState: ->
    visible: false
    value: ''
    type: dm.ui.InfoDialog.types.INFO

  render: ->
    {Dialog} = dm.ui
    {type} = @state
    buttonSet = dm.ui.Dialog.buttonSet.OK
    title = goog.string.toTitleCase type
    iconClass = "icon #{type}"

    content = switch type
      when dm.ui.InfoDialog.types.INFO then 'i'
      when dm.ui.InfoDialog.types.WARN then '!'


    `(
      <Dialog title={title} buttons={buttonSet} 
        visible={this.state.visible} onConfirm={this.hide} onCancel={this.hide}
      >
        <p className="info-dialog">
          <span className={iconClass}>{content}</span>
          {this.state.text}
        </p>
      </Dialog>
    )`

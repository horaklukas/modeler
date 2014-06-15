`/** @jsx React.DOM */`

goog.provide 'dm.ui.SimpleInputDialog'

goog.require 'dm.ui.Dialog'
goog.require 'goog.dom.selection'

dm.ui.SimpleInputDialog = React.createClass
  show: (defaultValue = '', title = '', cb) ->
    @setProps confirmCb: cb, title: title
    @setState visible: true, value: defaultValue

  componentDidUpdate: (prevProps, prevState) ->
    if prevState.visible is false and @state.visible is true
      inputField = @refs.inputValue.getDOMNode()
      
      goog.dom.selection.setStart inputField, 0
      goog.dom.selection.setEnd inputField, @state.value.length

  handleChange: (e) ->
    @setState value: e.target.value

  handleConfirm: ->
    if @props.confirmCb? then @props.confirmCb @state.value
    else console.warn 'Callback for SimpleInputDialog not defined'

    @hide()

  hide: ->
    @setState visible: false

  getInitialState: ->
    visible: false
    value: ''

  render: ->
    {Dialog} = dm.ui
    {visible, value} = @state
    buttonSet = dm.ui.Dialog.buttonSet.OK

    `(
      <Dialog title={this.props.title} buttons={buttonSet} visible={visible} 
        onConfirm={this.handleConfirm} onCancel={this.hide}
      >
        <p>
          <label>{this.props.title}</label>
        </p>
        <p>
          <input ref="inputValue" value={value} onChange={this.handleChange} />
        </p>
      </Dialog>
    )`

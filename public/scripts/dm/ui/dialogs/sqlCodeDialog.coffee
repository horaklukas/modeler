`/** @jsx React.DOM */`

goog.provide 'dm.ui.SqlCodeDialog'

goog.require 'dm.ui.Dialog'

dm.ui.SqlCodeDialog = React.createClass
  show: (sql) ->
    @setState visible: true, sqlCode: sql, err: null

  getInitialState: ->
    visible: false
    sqlCode: ''
    err: null

  handleSave: ->
    filename = @refs['filename'].getDOMNode().value

    unless filename then return @setState err: 'File name have to be filled'
    else @setState err: null

    @props.onSave? filename, @state.sqlCode

  render: ->
    {Dialog} = dm.ui
    {visible, sqlCode} = @state
    buttonSet = dm.ui.Dialog.buttonSet.OK

    info = `(<div className="state error">{this.state.err}</div>)` if @state.err?

    `(
      <Dialog title="SQL" buttons={buttonSet} visible={visible}>
        <textarea cols="100" rows="20" value={sqlCode} />
        {info}
        <div>
          <input ref="filename" defaultValue="" />
          <button onClick={this.handleSave}>Save</button>
        </div>
      </Dialog>
    )`

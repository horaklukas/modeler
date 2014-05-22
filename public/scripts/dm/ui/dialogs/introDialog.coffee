`/** @jsx React.DOM */`

goog.provide 'dm.ui.IntroDialog'

goog.require 'goog.object'

{Dialog} = dm.ui

dm.ui.IntroDialog = React.createClass
  statics:
    actions:
      'new': 'NEW MODEL'
      'load': 'LOAD MODEL'
      'byversion': 'SELECT VERSIONED MODEL - BLIND NOW'
      'fromdb': 'CREATE MODEL FROM DB - BLIND NOW'

  show: ->
    @setState visible: true

  hide: ->
    @setState visible: false

  handleSelect: (e) ->
    if @props.onSelect? then @props.onSelect e.target.value

  getInitialState: ->
    visible: false

  render: ->
    {visible} = @state
    title = 'Select action'
    buttonSet = dm.ui.Dialog.buttonSet.NONE

    actions = []

    goog.object.forEach dm.ui.IntroDialog.actions, ((label, id) ->
      actions.push(
        `( 
          <button className="big" key={id} value={id} 
            onClick={this.handleSelect}>{label}</button> 
        )`
      )
    ), this

    `(
    <Dialog title={title} visible={visible} buttons={buttonSet} >
      {actions}
    </Dialog>
    )`

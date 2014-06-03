`/** @jsx React.DOM */`

goog.provide 'dm.ui.SimpleInputDialog'

goog.require 'dm.ui.Dialog'
goog.require 'goog.dom.selection'

dm.ui.SimpleInputDialog = React.createClass
	show: (defaultValue = '', title = '', cb) ->
		@setProps confirmCb: cb, title: title
		@setState visible: true, value: defaultValue

		#goog.dom.selection.setText @refs.inputValue.getDOMNode(), @state.value
		#goog.dom.selection.setStart @refs.inputValue.getDOMNode(), 2
		#goog.dom.selection.setEnd @refs.inputValue.getDOMNode(), 5

	handleChange: (e) ->
		@setState value: e.target.value

	handleConfirm: ->
		if @props.confirmCb? then@props.confirmCb @state.value
		else console.warn 'Callback for SimpleInputDialog not defined'

	getInitialState: ->
		visible: false
		value: ''

	render: ->
		{visible, value} = @state
		buttonSet = dm.ui.Dialog.buttonSet.OK

		`(
			<Dialog title={this.props.title} buttons={buttonSet} visible={visible} 
				onConfirm={this.handleConfirm}
			>
				<p>
					<label>{this.props.title}</label>
				</p>
				<p>
					<input ref="inputValue" value={value} onChange={this.handleChange} />
				</p>
			</Dialog>
		)`

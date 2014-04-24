{TestUtils} = React.addons

goog.require 'dm.ui.Dialog'

describe 'component Dialog', ->
	dlg = null
	btns = null
	dlgRoot = null

	before ->
		dlg = TestUtils.renderIntoDocument dm.ui.Dialog()
		dlgRoot = TestUtils.findRenderedDOMComponentWithClass dlg, 'dialog-container'

	it 'should render title', ->
		dlg.setProps title: 'Titulek'

		titleElement = TestUtils.findRenderedDOMComponentWithClass dlg, 'title'
		expect(titleElement).to.have.deep.property 'props.children', 'Titulek'

	it 'should render ok cancel button in default', ->
		btns = TestUtils.scryRenderedDOMComponentsWithTag dlg, 'button'

		expect(btns[0]).to.have.deep.property 'props.children', 'Ok' 
		expect(btns[1]).to.have.deep.property 'props.children', 'Cancel'

	it 'should render ok button if passed OK as a button set type', ->
		dlg.setProps buttons: dm.ui.Dialog.buttonSet.OK	
		btn = TestUtils.findRenderedDOMComponentWithTag dlg, 'button'

		expect(btn).to.have.deep.property 'props.children', 'Ok' 

	it 'should render select button if passed SELECT as a button set type', ->
		dlg.setProps buttons: dm.ui.Dialog.buttonSet.SELECT	
		btn = TestUtils.findRenderedDOMComponentWithTag dlg, 'button'

		expect(btn).to.have.deep.property 'props.children', 'Select'

	it 'should hide dialog when clicked cancel', ->
		dlg.setProps visible: true, buttons: dm.ui.Dialog.buttonSet.OK_CANCEL
		btns = TestUtils.scryRenderedDOMComponentsWithTag dlg, 'button'
		expect(dlgRoot).to.have.deep.property 'props.style.display', 'block'

		TestUtils.Simulate.click btns[1]

		expect(dlgRoot).to.have.deep.property 'props.style.display', 'none'

	it 'should hide dialog when clicked ok and call confirm callback', ->
		cb = sinon.spy()
		dlg.setProps onConfirm: cb, visible: true
		btns = TestUtils.scryRenderedDOMComponentsWithTag dlg, 'button'
		expect(dlgRoot).to.have.deep.property 'props.style.display', 'block'

		TestUtils.Simulate.click btns[0] 

		expect(dlgRoot).to.have.deep.property 'props.style.display', 'none'
		cb.should.been.calledOnce

	it 'should not hide dialog when confirm callback return false', ->
		cb = sinon.stub().returns false
		dlg.setProps onConfirm: cb, visible: true
		btns = TestUtils.scryRenderedDOMComponentsWithTag dlg, 'button'		
		expect(dlgRoot).to.have.deep.property 'props.style.display', 'block'

		TestUtils.Simulate.click btns[0] 

		expect(dlgRoot).to.have.deep.property 'props.style.display', 'block'
controlPanel = require '../../public/scripts/components/controlPanel'

describe 'module controlPanel', ->
	#tb = new table RaphaelMock, 0, 0
	###
	it 'should have no tools at start', ->
		controlPanel.tools.should.be.an('array').with.length 0 

	describe 'method init', ->
		addTool = null
		toolSelected = null
		cb = null
		
		before ->
			addTool = sinon.stub controlPanel, 'addTool'
			toolSelected = sinon.stub controlPanel, 'toolSelected'
			cb = sinon.spy()
			controlPanel.init $('<div id="cp" />'), cb

		after ->
			addTool.restore()
			toolSelected.restore()	

		it 'should set passed obj as control panel object', ->
			controlPanel.obj.should.be.ok
			expect(controlPanel.obj.attr('id')).to.equal 'cp'

		it 'should call callback after controlPanel init', ->
			cb.should.be.calledOnce	

	describe 'addTool', ->
		it 'should add tool to list', ->
			fnc = -> return 1 + 1
			controlPanel.addTool 'tool1', {'click': fnc }
			controlPanel.tools.should.deep.equal [{name: 'tool1', events: {'click': fnc }}]
		
	describe 'toolSelected', ->
	###
		
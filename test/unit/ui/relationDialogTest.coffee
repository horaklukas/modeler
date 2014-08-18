goog.require 'dm.ui.RelationDialog'

{TestUtils} = React.addons

describe 'component RelationDialog', ->
  reld = null

  before ->
    reld = TestUtils.renderIntoDocument dm.ui.RelationDialog()

  describe 'method handleTypeChange', ->
    inputs = null

    beforeEach ->
      inputs = TestUtils.scryRenderedDOMComponentsWithClass reld, 'type'

    it 'should save identifying as a boolean value', ->
      reld.setState identifying: true
      expect(reld.state.identifying).to.equal true

      TestUtils.Simulate.change inputs[0]
      expect(reld.state.identifying).to.equal false

      TestUtils.Simulate.change inputs[1]
      expect(reld.state.identifying).to.equal true

  describe.skip 'method swapTables', ->
    ev = preventDefault: sinon.spy(), target: null
    gebc = null
    parent = null
    child = null

    before ->
      gebc = sinon.stub goog.dom, 'getElementByClass'
      parent = document.createElement 'div'
      child = document.createElement 'div'
      gebc.withArgs('parent').returns parent
      gebc.withArgs('child').returns child

    beforeEach ->
      reld.tablesSwaped = false
      parent.innerHTML = 'Parent name'
      child.innerHTML = 'Child name'
      ev.preventDefault.reset()
      gebc.reset()

    after ->
      gebc.restore()

    it 'should toggle swapped table flag', ->
      reld.swapTables ev

      reld.tablesSwaped.should.be.true
      
    it 'should swap content text inside child and parent', ->
      reld.swapTables ev

      parent.textContent.should.equal 'Child name'
      child.textContent.should.equal 'Parent name'

  describe 'method show', ->
    before -> 
      @isIdent = sinon.stub()
      @cardMod = sinon.stub().returns({
        cardinality: {parent: '1', child: 'n'}
        parciality: {parent: 1, child: 1}
      })
      @relModel = 
        isIdentifying: @isIdent
        getCardinalityParciality: @cardMod
        getName: sinon.stub()

      @tables = 
        'parent': id: 't1', name: 'parentTab1'  
        'child': id: 't2', name: 'parentTab1' 

    beforeEach ->
      @isIdent.reset()

    it 'should showdialog', ->
      reld.setState visible: false
      
      reld.show @relModel, @tables

      expect(reld.state).to.have.property 'visible', true

    it 'should set identifying relation', ->
      inputs = TestUtils.scryRenderedDOMComponentsWithClass reld, 'type'

      @isIdent.returns true
      
      reld.show @relModel, @tables
      
      expect(reld.state).to.have.property 'identifying', true
      expect(inputs[0].props).to.have.property 'checked', false
      expect(inputs[1].props).to.have.property 'checked', true

      @isIdent.returns false
      
      reld.show @relModel, @tables
      
      expect(reld.state).to.have.property 'identifying', false
      expect(inputs[0].props).to.have.property 'checked', true
      expect(inputs[1].props).to.have.property 'checked', false

    it 'should fill dialog title with tabels names', ->
      #@tables['parent']['name'] = 'table1'
      #@tables['child']['name'] = 'table2'
      @relModel.getName.returns 'relation1'

      @isIdent.returns true

      reld.show @relModel, @tables

      dialog = TestUtils.findRenderedComponentWithType reld, dm.ui.Dialog

      expect(dialog.props).to.have.property(
        'title', 'Relation "relation1"'
      )
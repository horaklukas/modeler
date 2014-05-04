goog.require 'dm.ui.TableDialog'
goog.require 'dm.model.Table'

{TestUtils} = React.addons

describe 'class TableDialog', ->
  props = null
  tabd = null
  dialogRoot = null

  before ->
    props = 
      types:
        'group1': ['type1g1', 'type2g1', 'type3g1', 'type4g1']
        'group2': ['type1g2', 'type2g2', 'type3g2', 'type4g2']

    tabd = TestUtils.renderIntoDocument dm.ui.TableDialog props
    dialogRoot = TestUtils.findRenderedComponentWithType tabd, Dialog

  it 'should left dialog hidden after render', ->
    expect(dialogRoot.state).to.have.property 'visible', false
  
  it 'should print error state if its not empty', ->
    tabd.setState 'errorState': 'Any state'

    state = TestUtils.findRenderedDOMComponentWithClass tabd, 'error'

    expect(state.props).to.have.property 'children', 'Any state'

  describe 'constructor', ->
    it 'should have private property columns that held columns changes', ->
      tabd.should.have.property('removed').that.is.null
      tabd.should.have.property('changed').that.is.null

  describe 'method show', ->
    fakeModel = null
    faketab = null
    gch = null
    listen = null
    svi = null
    sva = null

    before ->
      fakeModel = 
        getColumns: sinon.stub()
        getName: sinon.stub()
        getColumnsIdsByIndex: sinon.stub()

    beforeEach ->
      fakeModel.getColumns.reset()
      fakeModel.getName.reset()

      tabd.setState 'visible': false
      #faketab.getModel.reset()

    after ->

    it 'should show dialog', ->
      fakeModel.getName.returns ''
      fakeModel.getColumns.returns []
      
      tabd.show fakeModel

      expect(dialogRoot.state).to.have.property 'visible', true

    it 'should reset lists of changed and removed columns', ->
      tabd.show fakeModel

      expect(tabd).to.have.property('changed').that.deep.equal []
      expect(tabd).to.have.property('removed').that.deep.equal []

    it 'should set title of dialog with "unnamed" if name doesnt exist', ->
      fakeModel.getName.returns ''

      tabd.show fakeModel

      expect(dialogRoot.props).to.have.property 'title', 'Table "unnamed"'

    it 'should set title of dialog with table name if exists', ->
      fakeModel.getName.returns 'tab1'

      tabd.show fakeModel

      expect(dialogRoot.props).to.have.property 'title', 'Table "tab1"'

    it 'should set model name to tableName input', ->
      fakeModel.getName.returns 'TableName'

      tabd.show fakeModel

      nameInput = tabd.refs.tableName
      expect(nameInput.props).to.have.property 'value', 'TableName'

    it 'should add first "new" column to list of columns', ->
      fakeModel.getColumns.returns []
      
      tabd.show fakeModel

      expect(tabd.state.columns).to.have.length 1
      expect(tabd.state.columns[0]).to.deep.equal {
        name: null, type: null, isNotNull: null
      }

    it 'should show all columns and set its values', ->
      fakeModel.getColumns.returns [
        {name:'bob', type:'type1g1',  isNotNull: false}
        {name:'bobek', type:'type1g2',  isNotNull: true}
      ]

      tabd.show fakeModel

      cols = TestUtils.scryRenderedDOMComponentsWithClass tabd, 'tableColumn'

      expect(cols).to.have.length 3

  describe 'method nameChange', ->
    it 'should show new name', ->
      rows = TestUtils.scryRenderedDOMComponentsWithClass tabd, 'row'
      nameInput = TestUtils.scryRenderedDOMComponentsWithTag(tabd, 'input')[0] 
      
      TestUtils.Simulate.change nameInput, target: {value: 'New table name'} 

      expect(nameInput.props).to.have.property 'value', 'New table name'

  describe 'method addColumn', ->
    it 'should add new empty column to list of columns', ->
      tabd.setState columns: [
        {name: 'Julius', type: 'type1g1', isNotNull: false}
      ]
      
      tabd.addColumn()
      
      expect(tabd.state.columns).to.have.length 2
      expect(tabd.state.columns[1]).to.deep.equal {
        name: null, type: null, isNotNull: null
      }

    it 'should render empty row to the end', ->
      tabd.setState columns: [
        {name: 'Julius', type: 'type1g1', isNotNull: false}
        {name: 'Cesar', type: 'type1g2', isNotNull: true}
      ]
      
      cols = TestUtils.scryRenderedDOMComponentsWithClass tabd, 'tableColumn'
      expect(cols).to.have.length 2
      
      tabd.addColumn()

      cols = TestUtils.scryRenderedDOMComponentsWithClass tabd, 'tableColumn'
      expect(cols).to.have.length 3
      
    ###
    it 'should preserve not saved values in existing columns', ->
      tabd.colslist.innerHTML = 
        createRow('1', 'luke', 'son', no, yes, yes) +
        createRow('2', 'leia', 'daughter', yes, no, no) +
        createRow('3', 'obiwan', 'jedi', yes, no, yes)
      
      leia = goog.dom.getElementByClass 'name', tabd.colslist.childNodes[1]
      expect(leia).to.have.property 'value', 'leia'

      goog.dom.forms.setValue leia, 'amidala'

      tabd.addColumn()

      expect(leia).to.have.property 'value', 'amidala'
    ###

  describe 'method removeColumn', ->
    beforeEach ->
      tabd.removed = []

    it 'should remove the column element', ->
      tabd.setState columns: [
        {name:'athos', type:'type1g1',  isNotNull: false}
        {name:'portos', type:'type1g2', isNotNull: true}
        {name:'aramis', type:'type2g2', isNotNull: false}
      ]

      cols = TestUtils.scryRenderedComponentsWithType tabd, Column
      delBtn = TestUtils.findRenderedDOMComponentWithTag cols[1], 'button'

      TestUtils.Simulate.click delBtn

      cols = TestUtils.scryRenderedComponentsWithType tabd, Column
      expect(cols).to.have.length 2
      
      expect(cols[1].props).to.have.deep.property 'data.name', 'aramis'

    it 'it should add id of colum to list of removed', ->
      tabd.setState columns: [
        {id: 'chickid',  name:'chicken', type:'type1g1',  isNotNull: false}
        {id: 'punkid', name:'punk', type:'type1g2', isNotNull: true}
        {id: 'paoid', name:'pao', type:'type2g2', isNotNull: false}
      ]

      cols = TestUtils.scryRenderedDOMComponentsWithClass tabd, 'tableColumn'
      delBtn = TestUtils.findRenderedDOMComponentWithTag cols[2], 'button'

      TestUtils.Simulate.click delBtn

      expect(tabd.removed).to.deep.equal ['paoid']

    it 'should only remove element if column has not id (is newly created)', ->
      tabd.setState columns: [
        {id: 'patid',  name:'pat', type:'type1g1',  isNotNull: false}
        {id: 'matid', name:'mat', type:'type1g2', isNotNull: true}
        {id: null, name:'jaja', type:'type2g2', isNotNull: false}
        {id: null, name:'paja', type:'type2g1', isNotNull: false}
      ]

      cols = TestUtils.scryRenderedDOMComponentsWithClass tabd, 'tableColumn'
      expect(cols).to.have.length 4
      delBtn = TestUtils.findRenderedDOMComponentWithTag cols[3], 'button'
      
      TestUtils.Simulate.click delBtn

      cols = TestUtils.scryRenderedDOMComponentsWithClass tabd, 'tableColumn'
      expect(cols).to.have.length 3     
      delBtn = TestUtils.findRenderedDOMComponentWithTag cols[2], 'button'

      TestUtils.Simulate.click delBtn

      cols = TestUtils.scryRenderedDOMComponentsWithClass tabd, 'tableColumn'
      expect(cols).to.have.length 2
      expect(tabd).to.have.property('removed').that.deep.equal []
      
  describe 'method changeColumn', ->
    before ->
      sinon.spy tabd, 'changeColumn'

    beforeEach ->
      tabd.changed = []

    it 'should receive index of row, name and value of field', ->
      tabd.setState columns: [
        {id: 'oneid',  name:'one', type:'type1g1',  isNotNull: false}
        {id: 'twoid', name:'two', type:'type1g2', isNotNull: true}
        {id: null, name:'three', type:'type2g2',  isNotNull: false}
      ]

      cols = TestUtils.scryRenderedDOMComponentsWithClass tabd, 'tableColumn'
      nnl = TestUtils.findRenderedDOMComponentWithClass cols[1], 'isNotNull'
      nnl.getDOMNode().checked = false

      TestUtils.Simulate.change nnl

      tabd.changeColumn.should.been.calledOnce  
      tabd.changeColumn.should.been.calledWithExactly 1, 'isNotNull', false

    it 'should add index of row to list of changed', ->
      tabd.setState columns: [
        {id: 'oneid',  name:'one', type:'type1g1',  isNotNull: false}
        {id: 'twoid', name:'two', type:'type1g2', isNotNull: true}
        {id: null, name:'three', type:'type2g2',  isNotNull: false}
      ]

      cols = TestUtils.scryRenderedDOMComponentsWithClass tabd, 'tableColumn'
      pk = TestUtils.findRenderedDOMComponentWithClass cols[0], 'isPk'

      TestUtils.Simulate.change pk

      expect(tabd).to.have.property('changed').that.deep.equal ['oneid']

  describe 'method onConfirm', ->
    fakeModel = null
    unqStr = null
    pkStr = null

    before ->
      fakeModel = 
        getName: sinon.stub().returns 'Name'
        setName: sinon.spy()
        getColumns: sinon.stub().returns []
        setColumn: sinon.stub()
        removeColumn: sinon.spy()
        setIndex: sinon.spy()
        getColumnsIdsByIndex: sinon.stub()

      unqStr = dm.model.Table.index.UNIQUE
      pkStr = dm.model.Table.index.PK
      
      tabd.show fakeModel

    beforeEach ->
      tabd.changed = []
      tabd.removed = []
      fakeModel.setName.reset()
      fakeModel.setColumn.reset()
      fakeModel.removeColumn.reset()
      fakeModel.setIndex.reset()

    it 'should set error and reject dialog hide when name is empty', ->
      infobar = TestUtils.findRenderedDOMComponentWithClass tabd, 'error'
      tabd.setState name: ''

      expect(tabd.onConfirm()).to.be.false
      expect(infobar.props).to.have.property(
        'children', 'Table name have to be filled'
      )

    it 'should pass name of table from form to model', ->
      tabd.setState name: 'Table1'

      expect(tabd.onConfirm()).to.not.be.false
      fakeModel.setName.should.been.calledOnce
      fakeModel.setName.should.been.calledWithExactly 'Table1'

    it 'should set all columns in list for update to model', ->
      tabd.setState columns: [
        { name: 'col1', type: 'type1g1', isNotNull: true, isUnique: false,
        isPk: false, id: 'id1' }
        { name: 'col1', type: 'type1g2', isNotNull: true, isUnique: false,
        isPk: true, id: 'id3' }
        { name: 'col1', type: 'type2g1', isNotNull: false, isUnique: true,
        isPk: false, id: 'id5' }
      ]

      tabd.changed = ['id1', 'id5']

      tabd.onConfirm()

      fakeModel.setColumn.should.been.calledTwice
      fakeModel.setColumn.should.been.calledWithExactly(
        {name: 'col1', type: 'type1g1', isNotNull: true}, 'id1'
      )
      fakeModel.setColumn.should.been.calledWithExactly(
        {name: 'col1', type: 'type2g1', isNotNull: false}, 'id5'
      )

    it 'should remove all columns in list from model', ->
      tabd.setState columns: [
        { name: 'col1', type: 'type1g1', isNotNull: true, isUnique: false,
        isPk: false, id: 'id1' }
        { name: 'col1', type: 'type1g2', isNotNull: true, isUnique: false,
        isPk: true, id: 'id3' }
        { name: 'col1', type: 'type2g1', isNotNull: false, isUnique: true,
        isPk: false, id: 'id5' }
      ]

      tabd.removed = ['id1', 'id3']
      
      tabd.onConfirm()

      fakeModel.removeColumn.should.been.calledTwice
      fakeModel.removeColumn.should.been.calledWithExactly 'id1'
      fakeModel.removeColumn.should.been.calledWithExactly 'id3'

    it 'should add new column if it hasnt id and name is filled', ->
      tabd.setState columns: [
        { name: 'five', type: 'type1g1', isNotNull: true, isUnique: false,
        isPk: false, id: 'id1' }
        { name: '', type: 'type1g2', isNotNull: true, isUnique: false,
        isPk: true }
        { name: 'seven', type: 'type2g1', isNotNull: false, isUnique: true,
        isPk: false }
        { name: undefined, type: 'type2g1', isNotNull: false, isUnique: true,
        isPk: false }
      ]

      tabd.onConfirm()

      fakeModel.setColumn.should.been.calledOnce
      fakeModel.setColumn.should.been.calledWithExactly(
        {name: 'seven', type: 'type2g1', isNotNull: false}, undefined
      )
      
    it 'should add or delete primary and unique indexes for existing cols', ->
      tabd.setState columns: [
        { name: 'one', type: 'type1g1', isNotNull: true, isUnique: false,
        isPk: true, id: 'id1' }
        { name: 'two', type: 'type1g2', isNotNull: true, isUnique: false,
        isPk: true, id: 'id2' }
        { name: 'tree', type: 'type2g1', isNotNull: true, isUnique: true,
        isPk: false, id: 'id3' }
      ]

      fakeModel.setColumn.withArgs({name:'one',type:'type1g1',isNotNull:true})
        .returns 'id1'
      fakeModel.setColumn.withArgs({name:'tree',type:'type2g1',isNotNull:true})
        .returns 'id3'

      tabd.changed = ['id1', 'id3']

      tabd.onConfirm()

      fakeModel.setIndex.callCount.should.equal 4
      fakeModel.setIndex.should.been.calledWithExactly 'id1', unqStr, true
      fakeModel.setIndex.should.been.calledWithExactly 'id3', unqStr, false
      fakeModel.setIndex.should.been.calledWithExactly 'id1', pkStr, false
      fakeModel.setIndex.should.been.calledWithExactly 'id3', pkStr, true

    it 'should add unique or primary index for new columns', ->
      tabd.setState columns: [
        { name: 'one', type: 'type1g1', isNotNull: false, isUnique: true,
        isPk: true }
        { name: 'two', type: 'type1g2', isNotNull: true, isUnique: false,
        isPk: true, id: 'id2' }
        { name: 'tree', type: 'type2g1', isNotNull: true, isUnique: true,
        isPk: false }
        { name: 'four', type: 'type2g2', isNotNull: false, isUnique: false,
        isPk: false, id: 'id4' }
      ]

      fakeModel.setColumn.withArgs({name:'one',type:'type1g1',isNotNull:false})
        .returns 'id5'
      fakeModel.setColumn.withArgs({name:'tree',type:'type2g1',isNotNull:true})
        .returns 'id6'

      tabd.onConfirm()

      fakeModel.setIndex.should.been.calledThrice
      fakeModel.setIndex.should.been.calledWithExactly 'id5', unqStr, false
      fakeModel.setIndex.should.been.calledWithExactly 'id5', pkStr, false
      fakeModel.setIndex.should.been.calledWithExactly 'id6', unqStr, false
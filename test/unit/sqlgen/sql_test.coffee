goog.require 'dm.sqlgen.Sql'


describe 'class SQL generator', ->
  before ->
    # temporary mock
    global.React = renderComponent: ->

    sinon.stub dm.ui, 'SqlCodeDialog'
    @gen = dm.sqlgen.Sql.getInstance()    

  after ->
    dm.ui.SqlCodeDialog.restore()

  describe 'method getUniqueConstraintName', ->
    beforeEach ->
      @gen.relConstraintNames = []

    it 'should add index 0 at the end of name if its first name occurence', ->
      constrName = 'constr_chi_par_fk0'

      expect(@gen.getUniqueConstraintName 'child', 'parent').to.equal constrName

    it 'should add next index by constraint name occurences', ->
      @gen.relConstraintNames =   ['constr_chi_par_fk0', 'constr_chi_par_fk1']
      constrName = 'constr_chi_par_fk2'

      expect(@gen.getUniqueConstraintName 'child', 'parent').to.equal constrName

  describe 'method createColumn', ->
    it 'should return only name and uppercased type if column can be null', ->
      column = name: 'col', type: 'char', length: '', isNotNull: false 

      expect(@gen.createColumn column).to.equal '"col" CHAR'

    it 'should return also NOT NULL clause if column cant be null', ->
      column = name: 'col1', type: 'char', length: '', isNotNull: true 

      expect(@gen.createColumn column).to.equal '"col1" CHAR NOT NULL'

    it 'should append length to type if length is defined', ->
      column = name: 'col2', type: 'char', length: 15, isNotNull: false 

      expect(@gen.createColumn column).to.equal '"col2" CHAR(15)'

    it 'should not append length if its not defined or is null', ->
      column = name: 'col3', type: 'char', length: null, isNotNull: false 

      expect(@gen.createColumn column).to.equal '"col3" CHAR'

      column.length = ''

      expect(@gen.createColumn column).to.equal '"col3" CHAR'
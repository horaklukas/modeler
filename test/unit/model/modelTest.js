var Model, canvas, model;

Model = require("" + scriptsDir + "/components/model/model");

model = null;

canvas = $('canvas');

describe('class Model', function() {
  before(function() {
    return model = new Model('model1');
  });
  describe('constructor', function() {
    it('should throw error if name of model not defined', function() {
      return expect(function() {
        return new Model();
      }).to["throw"]('Model name must be specified!');
    });
    return it('should create empty lists of tables and relations', function() {
      model.tables.should.be.an('array').and.be.empty;
      return model.relations.should.be.an('array').and.be.empty;
    });
  });
  describe('method addTable', function() {
    global.Table = sinon.stub().returns({
      x: 40,
      y: 30
    });
    before(function() {
      return model.addTable('<canvas>', 38, 64);
    });
    it('should take passed canvas and positon make id and create table', function() {
      return Table.should.been.calledWith('<canvas>', 'tab_0', 38, 64);
    });
    return it('should save created table to list', function() {
      model.addTable('<canvas2>', 20, 160);
      model.tables.should.have.length(2);
      model.tables[0].should.deep.equal({
        x: 40,
        y: 30
      });
      return model.tables[1].should.deep.equal({
        x: 40,
        y: 30
      });
    });
  });
  describe('method addRelation', function() {
    var gtni;

    global.Relation = sinon.stub().returns({
      id: 'rel'
    });
    gtni = null;
    before(function() {
      gtni = sinon.stub(model, 'getTabNumberId');
      gtni.withArgs(1).returns(0);
      gtni.withArgs(2).returns(1);
      gtni.withArgs(3).returns(2);
      gtni.withArgs(4).returns(3);
      return model.tables = [
        {
          addRelation: sinon.spy()
        }, {
          addRelation: sinon.spy()
        }
      ];
    });
    after(function() {
      gtni.restore();
      return model.tables = [];
    });
    it('should return false if start or end table isnt found', function() {
      expect(model.addRelation('<canvas>', 3, 4)).to.be["false"];
      expect(model.addRelation('<canvas>', 1, 3)).to.be["false"];
      return expect(model.addRelation('<canvas>', 2, 4)).to.be["false"];
    });
    it('should add new relation to the list of relations', function() {
      model.addRelation('<c>', 1, 2);
      expect(Relation).to.be.calledWith('<c>', model.tables[0], model.tables[1]);
      expect(model.relations).to.have.length(1);
      return expect(model.relations[0]).to.deep.equal({
        id: 'rel'
      });
    });
    return it('should add relation reference to end tables', function() {
      model.addRelation('<c>', 1, 2);
      expect(model.tables[0].addRelation).to.been.calledWith({
        id: 'rel'
      });
      return expect(model.tables[1].addRelation).to.been.calledWith({
        id: 'rel'
      });
    });
  });
  return describe('method getTabNumberId', function() {
    it('should return the id number if id has right format', function() {
      expect(model.getTabNumberId('tab_0'), 'tab_0').to.be.a('number').and.equal(0);
      expect(model.getTabNumberId('tab_23'), 'tab_23').to.be.a('number').and.equal(23);
      return expect(model.getTabNumberId('tab_123'), 'tab_123').to.be.a('number').and.equal(123);
    });
    return it('should return false id if has wrong format', function() {
      expect(model.getTabNumberId('tab_12f'), 'tab_12f').to.be["false"];
      expect(model.getTabNumberId('tabb_13'), 'tab_13').to.be["false"];
      expect(model.getTabNumberId('tab_ds2'), 'tab_ds2').to.be["false"];
      return expect(model.getTabNumberId('tab_'), 'tab_').to.be["false"];
    });
  });
});

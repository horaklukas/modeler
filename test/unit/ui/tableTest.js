goog.require('dm.ui.Table');

goog.require('goog.events.EventTarget');

describe('class Table', function() {
  var fakeModel, tab;

  tab = null;
  fakeModel = null;
  before(function() {
    fakeModel = new goog.events.EventTarget();
    fakeModel.getName = sinon.stub();
    fakeModel.getColumns = sinon.stub();
    return tab = new dm.ui.Table(fakeModel);
  });
  describe('constructor', function() {
    it('should save passed model', function() {
      return expect(tab).to.have.property('model_', fakeModel);
    });
    it('should init position at 0,0 if coordinates not passed', function() {
      expect(tab).to.have.deep.property('position_.x', 0);
      return expect(tab).to.have.deep.property('position_.y', 0);
    });
    return it('should init position at passed coordinates', function() {
      var tab2;

      tab2 = new dm.ui.Table(fakeModel, 34, 265);
      expect(tab2).to.have.deep.property('position_.x', 34);
      return expect(tab2).to.have.deep.property('position_.y', 265);
    });
  });
  describe('method createDom', function() {
    var gi, gm, sei;

    gm = null;
    gi = null;
    sei = null;
    before(function() {
      gm = sinon.stub(tab, 'getModel');
      gi = sinon.stub(tab, 'getId');
      return sei = sinon.stub(tab, 'setElementInternal');
    });
    beforeEach(function() {
      gm.reset();
      gi.reset();
      return sei.reset();
    });
    after(function() {
      gm.restore();
      gi.restore();
      return sei.restore();
    });
    it('should save created element', function() {
      fakeModel.getName.returns('');
      fakeModel.getColumns.returns([]);
      gm.returns(fakeModel);
      gi.returns(123);
      tab.createDom();
      sei.should.been.calledOnce.and;
      return sei.lastCall.args[0].should.be.truthy;
    });
    it('should save table name to its head', function() {
      fakeModel.getName.returns('TAB1');
      gm.returns(fakeModel);
      tab.createDom();
      expect(tab).to.have.deep.property('head_.innerHTML', 'TAB1');
      return expect(tab).to.have.deep.property('head_.className', 'head');
    });
    return it('should save table name to its body', function() {
      fakeModel.getName.returns('');
      fakeModel.getColumns.returns([
        {
          name: 'col1',
          isPk: false
        }
      ]);
      gi.returns('i1d');
      gm.returns(fakeModel);
      tab.createDom();
      return expect(tab).to.have.deep.property('body_.className', 'body');
    });
  });
  describe('method setPosition', function() {
    var iid, ssp;

    iid = null;
    ssp = null;
    before(function() {
      iid = sinon.stub(tab, 'isInDocument');
      return ssp = sinon.stub(goog.style, 'setPosition');
    });
    beforeEach(function() {
      iid.reset();
      return ssp.reset();
    });
    after(function() {
      iid.restore();
      return ssp.restore();
    });
    it('should set new table position', function() {
      tab.setPosition(69, 96);
      expect(tab).to.have.deep.property('position_.x', 69);
      return expect(tab).to.have.deep.property('position_.y', 96);
    });
    return it('should set position of element if it is in document already', function() {
      iid.returns(true);
      tab.setPosition(14, 41);
      ssp.should.been.calledOnce;
      ssp.lastCall.args[1].should.equal(14);
      return ssp.lastCall.args[2].should.equal(41);
    });
  });
  describe.skip('method getConnPoints', function() {
    var obj;

    obj = null;
    before(function() {
      tab = new Table(canvas, 'id', 20, 30, 160, 300);
      return obj = tab.getConnPoints();
    });
    it('should return object containing connection point for each side', function() {
      return expect(obj).to.be.an('object').and.have.keys(['top', 'right', 'bottom', 'left']);
    });
    it('should have x and y coordinates for each connection point', function() {
      expect(obj.top).to.have.keys(['x', 'y']);
      expect(obj.right).to.have.keys(['x', 'y']);
      expect(obj.bottom).to.have.keys(['x', 'y']);
      return expect(obj.left).to.have.keys(['x', 'y']);
    });
    it('should count correct connection points positions', function() {
      expect(obj.top).to.have.deep.equal({
        x: 100,
        y: 30
      });
      expect(obj.right).to.have.deep.equal({
        x: 181,
        y: 180
      });
      expect(obj.bottom).to.have.deep.equal({
        x: 100,
        y: 331
      });
      return expect(obj.left).to.have.deep.equal({
        x: 20,
        y: 180
      });
    });
    return it('should count points for each table separetlly', function() {
      var obj2, tab2;

      tab2 = new Table(canvas, 'id2', 78, 69, 75, 205);
      obj2 = tab2.getConnPoints();
      return expect(obj).to.not.deep.equal(obj2);
    });
  });
  describe.skip('method addRelation', function() {
    it('should add relations to table', function() {
      tab = new Table(canvas, 'i', 10, 10);
      expect(tab.relations).to.be.empty;
      tab.addRelation('rel1');
      tab.addRelation('rel2');
      tab.addRelation('rel3');
      return expect(tab.relations).to.have.length(3).and.deep.equal(['rel1', 'rel2', 'rel3']);
    });
    return it('should set clear list of table\'s relations for each new table', function() {
      var tab1, tab3;

      tab1 = new Table(canvas, 'i', 20, 30);
      tab1.addRelation('rel2');
      tab1.addRelation('rel5');
      expect(tab1.relations).to.have.length(2).and.deep.equal(['rel2', 'rel5']);
      tab3 = new Table(canvas, 'd', 40, 50);
      return expect(tab3.relations).to.be.an('array').and.be.empty;
    });
  });
  describe('method addColumn', function() {
    before(function() {
      return tab = new dm.ui.Table(fakeModel);
    });
    return it('should add column to the end of columns', function() {
      fakeModel.getColumns.returns([
        {
          name: 'col1',
          isPk: false
        }, {
          name: 'col2',
          isPk: true
        }
      ]);
      tab.createDom();
      expect(tab).to.have.deep.property('body_.childNodes.length', 3);
      tab.addColumn({
        name: 'col3',
        isPk: true
      });
      return expect(tab).to.have.deep.property('body_.childNodes.length', 4);
    });
  });
  describe('method updateColumn', function() {
    before(function() {
      return tab = new dm.ui.Table(fakeModel);
    });
    beforeEach(function() {
      fakeModel.getColumns.returns([
        {
          name: 'col3',
          isPk: false
        }, {
          name: 'col4',
          isPk: false
        }, {
          name: 'col5',
          isPk: true
        }
      ]);
      return tab.createDom();
    });
    it('should left count of columns same as it was', function() {
      expect(tab).to.have.deep.property('body_.childNodes.length', 4);
      tab.updateColumn(1, {
        name: 'col3',
        isPk: true
      });
      return expect(tab).to.have.deep.property('body_.childNodes.length', 4);
    });
    return it('should replace old column element with new column element', function() {
      expect(tab).to.have.deep.property('body_.childNodes[2].innerText', 'col4');
      tab.updateColumn(1, {
        name: 'col6',
        isPk: false
      });
      return expect(tab).to.have.deep.property('body_.childNodes[2].innerText', 'col6');
    });
  });
  return describe('method removeColumn', function() {
    before(function() {
      return tab = new dm.ui.Table(fakeModel);
    });
    beforeEach(function() {
      fakeModel.getColumns.returns([
        {
          name: 'col1',
          isPk: false
        }, {
          name: 'col2',
          isPk: false
        }, {
          name: 'col3',
          isPk: false
        }, {
          name: 'col4',
          isPk: true
        }
      ]);
      return tab.createDom();
    });
    it('should remove one column element', function() {
      expect(tab).to.have.deep.property('body_.childNodes.length', 5);
      tab.removeColumn(2);
      return expect(tab).to.have.deep.property('body_.childNodes.length', 4);
    });
    return it('should remove column with passed index', function() {
      expect(tab).to.have.deep.property('body_.childNodes[2].innerText', 'col2');
      tab.removeColumn(1);
      return expect(tab).to.have.deep.property('body_.childNodes[2].innerText', 'col3');
    });
  });
});

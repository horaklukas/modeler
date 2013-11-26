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
  describe.skip('method startTable', function() {
    var fakeEv, mPos;

    fakeEv = {
      pageX: 110,
      pageY: 230
    };
    mPos = null;
    before(function() {
      tab = new Table(canvas, 'id', 0, 0);
      return mPos = sinon.stub(tab.table, 'position').returns({
        left: 60,
        top: 100
      });
    });
    after(function() {
      return mPos.reset();
    });
    return it('should set position, relative and current coordinates', function() {
      tab.startTable(fakeEv);
      tab.position.current.should.deep.equal({
        x: 60,
        y: 100
      });
      tab.position.startmove.relative.should.deep.equal({
        x: 60,
        y: 100
      });
      return tab.position.startmove.absolute.should.deep.equal({
        x: 110,
        y: 230
      });
    });
  });
  describe.skip('method moveTable', function() {
    var fakeEv, mCss, mPos, startEv;

    fakeEv = {
      pageX: 100,
      pageY: 150,
      data: {
        maxX: 300,
        maxY: 500
      }
    };
    startEv = {
      pageX: 100,
      pageY: 150
    };
    mPos = null;
    mCss = null;
    before(function() {
      tab = new Table(canvas, 'id', 20, 20, 70, 50);
      mPos = sinon.stub(tab.table, 'position').returns({
        left: 20,
        top: 30
      });
      return mCss = sinon.stub(tab.table, 'css');
    });
    after(function() {
      mPos.reset();
      return mCss.reset();
    });
    it('should add class `move` to table', function() {
      tab.moveTable({
        pageX: 0,
        pageY: 0,
        data: {
          maxX: 30,
          maxY: 50
        }
      });
      return expect(tab.table.hasClass('move')).to.be["true"];
    });
    it('should count correct coordinates when imputing coordintes', function() {
      tab.startTable(startEv);
      fakeEv.pageX = 130;
      fakeEv.pageY = 175;
      tab.moveTable(fakeEv);
      mCss.should.been.calledWithExactly({
        left: 50,
        top: 55
      });
      return tab.position.current.should.deep.equal({
        x: 50,
        y: 55
      });
    });
    it('should count correct coordinates when subtracting coordintes', function() {
      tab.startTable(startEv);
      fakeEv.pageX = 90;
      fakeEv.pageY = 125;
      tab.moveTable(fakeEv);
      mCss.should.been.calledWithExactly({
        left: 10,
        top: 5
      });
      return tab.position.current.should.deep.equal({
        x: 10,
        y: 5
      });
    });
    it('should set coords to canvas max minus table size if table is outside canvas', function() {
      tab.startTable(startEv);
      fakeEv.pageX = 460;
      fakeEv.pageY = 690;
      tab.moveTable(fakeEv);
      mCss.should.been.calledWithExactly({
        left: 230,
        top: 450
      });
      return tab.position.current.should.deep.equal({
        x: 230,
        y: 450
      });
    });
    it('should set coords to canvas min if coords are lower than min', function() {
      tab.startTable(startEv);
      fakeEv.pageX = 30;
      fakeEv.pageY = 100;
      tab.moveTable(fakeEv);
      mCss.should.been.calledWithExactly({
        left: 0,
        top: 0
      });
      return tab.position.current.should.deep.equal({
        x: 0,
        y: 0
      });
    });
    return it('should recount position of each related relation', function() {
      var cb;

      cb = sinon.spy();
      tab.relations = [
        {
          recountPosition: cb
        }, {
          recountPosition: cb
        }
      ];
      tab.moveTable(fakeEv);
      return cb.should.been.calledTwice;
    });
  });
  describe.skip('method stopTable', function() {
    before(function() {
      return tab = new Table(canvas, 'id', 0, 0);
    });
    return it('should remove class `move` from table', function() {
      tab.moveTable({
        pageX: 0,
        pageY: 0,
        data: {
          maxX: 30,
          maxY: 50
        }
      });
      expect(tab.table.hasClass('move')).to.be["true"];
      tab.stopTable({
        pageX: 0,
        pageY: 0,
        data: {
          maxX: 30,
          maxY: 50
        }
      });
      return expect(tab.table.hasClass('move')).to.be["false"];
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

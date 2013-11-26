goog.require('dm.ui.Canvas');

goog.require('goog.events.Event');

describe('class Canvas', function() {
  var can, ev;

  can = null;
  ev = null;
  before(function() {
    var rootElem;

    rootElem = document.createElement('div');
    rootElem.id = 'rootElem';
    document.body.appendChild(rootElem);
    can = new dm.ui.Canvas();
    ev = new goog.events.Event();
    return can.render(rootElem);
  });
  describe('constructor', function() {
    return it('should init properties for hold moving object', function() {
      can.should.have.deep.property('move.object', null);
      return can.should.have.deep.property('move.offset', null);
    });
  });
  describe('enterDocument', function() {
    var can2, parentElement;

    parentElement = null;
    can2 = null;
    before(function() {
      parentElement = document.createElement('div');
      parentElement.style.setProperty('width', '600px');
      parentElement.style.setProperty('height', '300px');
      return document.body.appendChild(parentElement);
    });
    beforeEach(function() {
      return can2 = new dm.ui.Canvas();
    });
    it('should set size information taken from canvas element', function() {
      can2.render(parentElement);
      can2.should.have.deep.property('size_.width', 600);
      return can2.should.have.deep.property('size_.height', 300);
    });
    return it('should create and save clue table', function() {
      var styles;

      can2.render(parentElement);
      can2.should.have.property('clueTable');
      styles = can2.clueTable.style.cssText;
      expect(styles).to.contain('display: none');
      expect(styles).to.contain('top: 0');
      return expect(styles).to.contain('left: 0');
    });
  });
  describe('method onDblClick', function() {
    var die, gch, goibe;

    goibe = null;
    gch = null;
    die = null;
    before(function() {
      goibe = sinon.stub(can, 'getObjectIdByElement');
      gch = sinon.stub(can, 'getChild');
      return die = sinon.stub(can, 'dispatchEvent');
    });
    beforeEach(function() {
      goibe.reset();
      gch.reset();
      return die.reset();
    });
    after(function() {
      goibe.restore();
      gch.restore();
      return die.restore();
    });
    it('should return false if target element is canvas div wrapper', function() {
      ev.target = can.rootElement_;
      return expect(can.onDblClick(ev)).to.be["false"];
    });
    return it('should get right child object and dispatch event with it', function() {
      ev.target = 'some div';
      goibe.withArgs('some div').returns('object');
      gch.withArgs('object').returns('fakeobject');
      can.onDblClick(ev);
      die.should.been.calledOnce;
      return die.lastCall.args[0].should.have.property('target', 'fakeobject');
    });
  });
  describe('onCaughtTable', function() {
    return it('should save object start moving data', function() {
      ev.target = 'tableObject';
      ev.catchOffset = {
        x: 34,
        y: 65
      };
      can.onCaughtTable(ev);
      can.should.have.deep.property('move.object', 'tableObject');
      return can.should.have.deep.property('move.offset').that.deep.equal({
        x: 34,
        y: 65
      });
    });
  });
  describe('moveTable', function() {
    var grp;

    grp = null;
    before(function() {
      grp = sinon.stub(goog.style, 'getRelativePosition');
      return can.move.object = {
        setPosition: sinon.stub(),
        getSize: sinon.stub().returns({
          width: 30,
          height: 50
        }),
        dispatchEvent: sinon.spy()
      };
    });
    beforeEach(function() {
      grp.reset();
      can.move.object.setPosition.reset();
      can.move.offset = {
        x: 0,
        y: 0
      };
      return can.size_ = {
        width: 500,
        height: 340
      };
    });
    after(function() {
      return grp.restore();
    });
    it('should set position to min if position is less than canvas min', function() {
      grp.returns({
        x: -245,
        y: -160
      });
      can.move.offset = {
        x: 5,
        y: 40
      };
      can.moveTable(ev);
      can.move.object.setPosition.should.been.calledOnce;
      return can.move.object.setPosition.should.been.calledWithExactly(0, 0);
    });
    it('should set position to max if position is greater than canvas max', function() {
      grp.returns({
        x: 562,
        y: 402
      });
      can.move.offset = {
        x: 35,
        y: 40
      };
      can.moveTable(ev);
      can.move.object.setPosition.should.been.calledOnce;
      return can.move.object.setPosition.should.been.calledWithExactly(470, 290);
    });
    return it('should count position of table and set it', function() {
      grp.returns({
        x: 345,
        y: 268
      });
      can.move.offset = {
        x: 34,
        y: 65
      };
      can.moveTable(ev);
      can.move.object.setPosition.should.been.calledOnce;
      return can.move.object.setPosition.should.been.calledWithExactly(311, 203);
    });
  });
  return describe('getObjectIdByElement', function() {
    it('should return null if passed canvas element', function() {
      return expect(can.getObjectIdByElement(can.rootElement_)).to.be["null"];
    });
    it('should return id if passed root element of object', function() {
      var rootElement;

      rootElement = document.createElement('div');
      rootElement.id = 'elemid';
      can.rootElement_.appendChild(rootElement);
      return expect(can.getObjectIdByElement(rootElement)).to.equal('elemid');
    });
    return it('should return id if passed any deeper element of object', function() {
      var innerElement1, innerElement2, innerElement3;

      innerElement1 = document.createElement('div');
      innerElement1.id = 'inner1';
      innerElement2 = document.createElement('div');
      innerElement3 = document.createElement('div');
      innerElement2.appendChild(innerElement3);
      innerElement1.appendChild(innerElement2);
      can.rootElement_.appendChild(innerElement1);
      return expect(can.getObjectIdByElement(innerElement3)).to.equal('inner1');
    });
  });
});

goog.require('dm.ui.Toolbar');

goog.require('dm.ui.tools.CreateTable');

describe('module Toolbar', function() {});

describe('module CreateTable', function() {
  var cta, ev, gsz;

  gsz = null;
  cta = null;
  ev = null;
  before(function() {
    gsz = sinon.stub(goog.style, 'getSize').returns({
      width: 30,
      height: 50
    });
    cta = new dm.ui.tools.CreateTable;
    return cta.areaSize = {
      width: 500,
      height: 340
    };
  });
  after(function() {
    return gsz.restore();
  });
  return describe('moveTable', function() {
    var gop, grp, spos;

    grp = null;
    spos = null;
    gop = null;
    before(function() {
      grp = sinon.stub(goog.style, 'getRelativePosition');
      spos = sinon.stub(goog.style, 'setPosition');
      gop = sinon.stub(goog.style, 'getOffsetParent');
      return cta.table = 'table';
    });
    beforeEach(function() {
      grp.reset();
      spos.reset();
      gop.reset();
      return gsz.reset();
    });
    after(function() {
      grp.restore();
      spos.restore();
      return gop.restore();
    });
    it('should set position to min if position is less than canvas min', function() {
      grp.returns({
        x: -245,
        y: -160
      });
      cta.moveTable(ev);
      spos.should.been.calledOnce;
      return spos.should.been.calledWithExactly('table', 0, 0);
    });
    it('should set position to max if position is greater than canvas max', function() {
      grp.returns({
        x: 562,
        y: 402
      });
      cta.moveTable(ev);
      spos.should.been.calledOnce;
      return spos.should.been.calledWithExactly('table', 468, 288);
    });
    return it('should count position of table and set it', function() {
      grp.returns({
        x: 345,
        y: 268
      });
      cta.moveTable(ev);
      spos.should.been.calledOnce;
      return spos.should.been.calledWithExactly('table', 345, 268);
    });
  });
});

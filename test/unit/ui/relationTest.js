goog.require('dm.ui.Relation');

goog.require('goog.events.EventTarget');

goog.require('goog.graphics.CanvasGraphics');

describe('class Relation', function() {
  var fakeModel, gr, rel;

  rel = null;
  gr = null;
  fakeModel = null;
  before(function() {
    gr = new goog.graphics.CanvasGraphics;
    fakeModel = new goog.events.EventTarget();
    fakeModel.getName = sinon.stub();
    fakeModel.getColumns = sinon.stub();
    return rel = new dm.ui.Relation(gr);
  });
  describe('constructor', function() {});
  describe('getPathDistance', function() {
    it('should return distance if position type are equal', function() {
      var d;

      d = rel.getPathDistance('right', {
        x: 10,
        y: 30
      }, 'right', {
        x: 45,
        y: 61
      });
      return expect(d).should.be.a.number;
    });
    it('should count distance between two points as sum of two distances', function() {
      var d;

      d = rel.getPathDistance('top', {
        x: 23,
        y: 34
      }, 'top', {
        x: 45,
        y: 67
      });
      return expect(d).to.equal(55);
    });
    return it('should count positive distance if second point is before first', function() {
      var d;

      d = rel.getPathDistance('top', {
        x: 54,
        y: 123
      }, 'top', {
        x: 45,
        y: 67
      });
      return expect(d).to.equal(65);
    });
  });
  describe('getTableConnectionPoints', function() {
    var gb;

    gb = null;
    before(function() {
      return gb = sinon.stub(goog.style, 'getBounds');
    });
    beforeEach(function() {
      return gb.reset();
    });
    after(function() {
      return gb.restore();
    });
    it('should count top position from table bounds', function() {
      var coord;

      gb.returns({
        left: 38,
        top: 45,
        width: 124
      });
      coord = rel.getTableConnectionPoints({
        getElement: function() {
          return 'table';
        }
      });
      coord.should.have.deep.property('top.x', 98);
      return coord.should.have.deep.property('top.y', 14);
    });
    it('should count right position from table bounds', function() {
      var coord;

      gb.returns({
        left: 74,
        top: 63,
        width: 56,
        height: 88
      });
      coord = rel.getTableConnectionPoints({
        getElement: function() {
          return 'table';
        }
      });
      coord.should.have.deep.property('right.x', 128);
      return coord.should.have.deep.property('right.y', 76);
    });
    it('should count bottom position from table bounds', function() {
      var coord;

      gb.returns({
        left: 81,
        top: 15,
        width: 130,
        height: 90
      });
      coord = rel.getTableConnectionPoints({
        getElement: function() {
          return 'table';
        }
      });
      coord.should.have.deep.property('bottom.x', 144);
      return coord.should.have.deep.property('bottom.y', 74);
    });
    return it('should count left position from table bounds', function() {
      var coord;

      gb.returns({
        left: 14,
        top: 13,
        height: 90
      });
      coord = rel.getTableConnectionPoints({
        getElement: function() {
          return 'table';
        }
      });
      coord.should.have.deep.property('left.x', 12);
      return coord.should.have.deep.property('left.y', 27);
    });
  });
  return describe.skip('getRelationPath', function() {
    var fakepath, grp;

    grp = null;
    fakepath = {
      moveTo: sinon.spy(),
      lineTo: sinon.spy()
    };
    before(function() {
      return grp = sinon.stub(rel, 'getRelationPoints');
    });
    beforeEach(function() {
      fakepath.moveTo.reset();
      return fakepath.lineTo.reset();
    });
    after(function() {
      return grp.restore();
    });
    it('should move to right points when relation is vertical', function() {
      grp.returns({
        start: {
          edge: 'top',
          coords: {
            x: 23,
            y: 23
          }
        },
        stop: {
          edge: 'bottom',
          coords: {
            x: 20,
            y: 54
          }
        }
      });
      rel.getRelationPath(fakepath);
      fakepath.moveTo.should.been.calledWithExactly(21, 23);
      fakepath.lineTo.should.been.calledWithExactly(18, 54);
      fakepath.lineTo.should.been.calledWithExactly(22, 54);
      return fakepath.lineTo.should.been.calledWithExactly(25, 23);
    });
    it('should move to right points when relation is horizontal', function() {
      grp.returns({
        start: {
          edge: 'left',
          coords: {
            x: 23,
            y: 51
          }
        },
        stop: {
          edge: 'right',
          coords: {
            x: 68,
            y: 54
          }
        }
      });
      rel.getRelationPath(fakepath);
      fakepath.moveTo.should.been.calledWithExactly(23, 49);
      fakepath.lineTo.should.been.calledWithExactly(68, 52);
      fakepath.lineTo.should.been.calledWithExactly(68, 56);
      return fakepath.lineTo.should.been.calledWithExactly(23, 53);
    });
    it('should move to right points when relation is increasing to right', function() {
      grp.returns({
        start: {
          edge: 'right',
          coords: {
            x: 23,
            y: 90
          }
        },
        stop: {
          edge: 'bottom',
          coords: {
            x: 79,
            y: 22
          }
        }
      });
      rel.getRelationPath(fakepath);
      fakepath.moveTo.should.been.calledWithExactly(23, 88);
      fakepath.lineTo.should.been.calledWithExactly(77, 22);
      fakepath.lineTo.should.been.calledWithExactly(81, 22);
      return fakepath.lineTo.should.been.calledWithExactly(23, 92);
    });
    it('should move to right points when relation is increasing to left', function() {
      grp.returns({
        start: {
          edge: 'left',
          coords: {
            x: 65,
            y: 97
          }
        },
        stop: {
          edge: 'bottom',
          coords: {
            x: 31,
            y: 35
          }
        }
      });
      rel.getRelationPath(fakepath);
      fakepath.moveTo.should.been.calledWithExactly(65, 95);
      fakepath.lineTo.should.been.calledWithExactly(33, 35);
      fakepath.lineTo.should.been.calledWithExactly(29, 35);
      return fakepath.lineTo.should.been.calledWithExactly(65, 99);
    });
    it('should move to right points when relation is decreasing to right', function() {
      grp.returns({
        start: {
          edge: 'right',
          coords: {
            x: 13,
            y: 56
          }
        },
        stop: {
          edge: 'top',
          coords: {
            x: 67,
            y: 104
          }
        }
      });
      rel.getRelationPath(fakepath);
      fakepath.moveTo.should.been.calledWithExactly(13, 54);
      fakepath.lineTo.should.been.calledWithExactly(65, 104);
      fakepath.lineTo.should.been.calledWithExactly(69, 104);
      return fakepath.lineTo.should.been.calledWithExactly(13, 58);
    });
    return it('should move to right points when relation is decreasing to left', function() {
      grp.returns({
        start: {
          edge: 'left',
          coords: {
            x: 89,
            y: 42
          }
        },
        stop: {
          edge: 'top',
          coords: {
            x: 19,
            y: 98
          }
        }
      });
      rel.getRelationPath(fakepath);
      fakepath.moveTo.should.been.calledWithExactly(89, 40);
      fakepath.lineTo.should.been.calledWithExactly(17, 98);
      fakepath.lineTo.should.been.calledWithExactly(21, 98);
      return fakepath.lineTo.should.been.calledWithExactly(89, 44);
    });
  });
});

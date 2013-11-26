var Relation, canvas, etab, rel, stab;

Relation = require("" + scriptsDir + "/components/model/relation");

rel = null;

canvas = {
  path: sinon.stub().returns({
    attr: sinon.spy()
  })
};

stab = {
  getConnPoints: sinon.spy()
};

etab = {
  getConnPoints: sinon.spy()
};

describe('class Relation', function() {
  describe('constructor', function() {});
  describe('method recountPosition', function() {
    var gcp;

    gcp = null;
    before(function() {
      var fakeEndPoints;

      fakeEndPoints = {
        start: {
          x: 20,
          y: 40
        },
        break1: {
          x: 120,
          y: 100
        },
        break2: {
          x: 120,
          y: 100
        },
        stop: {
          x: 220,
          y: 160
        }
      };
      gcp = sinon.stub(Relation.prototype, 'getRelationPoints').returns(fakeEndPoints);
      return rel = new Relation(canvas, stab, etab);
    });
    beforeEach(function() {
      return gcp.reset();
    });
    after(function() {
      return gcp.restore();
    });
    return it('should count correct path from got end points coordinates', function() {
      rel.obj.attr.reset();
      rel.recountPosition();
      rel.obj.attr.should.be.calledOnce;
      return rel.obj.attr.should.be.calledWithExactly('path', 'M20,40L120,100L120,100L220,160');
    });
  });
  describe('method getPathDistance', function() {
    it('should return false if points are opossite', function() {
      var less, more;

      less = {
        x: 20,
        y: 30
      };
      more = {
        x: 70,
        y: 80
      };
      expect(rel.getPathDistance('left', less, 'right', more)).to.be["false"];
      expect(rel.getPathDistance('right', more, 'left', less)).to.be["false"];
      expect(rel.getPathDistance('top', less, 'bottom', more)).to.be["false"];
      return expect(rel.getPathDistance('bottom', more, 'top', less)).to.be["false"];
    });
    return it('should return distance if points arent at same position', function() {
      var c;

      c = {
        x: 0,
        y: 0
      };
      expect(rel.getPathDistance('left', c, 'left', c)).to.be.a('number');
      expect(rel.getPathDistance('right', c, 'right', c)).to.be.a('number');
      expect(rel.getPathDistance('top', c, 'top', c)).to.be.a('number');
      return expect(rel.getPathDistance('bottom', c, 'bottom', c)).to.be.a('number');
    });
  });
  return describe('method getBreakPoints', function() {
    it('should return array with two breaks at indexes 0 and 1', function() {
      var br;

      br = rel.getBreakPoints({
        x: 20,
        y: 30
      }, 'left', {
        x: 20,
        y: 30
      }, 'top');
      return expect(br).to.be.an('array').and.have.length(2);
    });
    it('should set x and y coordinates for both breaks', function() {
      var br;

      br = rel.getBreakPoints({
        x: 20,
        y: 30
      }, 'left', {
        x: 20,
        y: 30
      }, 'top');
      expect(br[0]).to.be.an('object').to.have.property('x').and.that.is.a('number');
      expect(br[0]).to.have.property('y').and.that.is.a('number');
      expect(br[1]).to.be.an('object').to.have.property('x').and.that.is.a('number');
      return expect(br[1]).to.have.property('y').and.that.is.a('number');
    });
    it('should break at y coordinate if positions are left and right', function() {
      var br;

      br = rel.getBreakPoints({
        x: 20,
        y: 30
      }, 'left', {
        x: 90,
        y: 60
      }, 'right');
      expect(br[0]).to.deep.equal({
        x: 55,
        y: 30
      });
      return expect(br[1]).to.deep.equal({
        x: 55,
        y: 60
      });
    });
    it('should break at x coordinate if positions are top and bottom', function() {
      var br;

      br = rel.getBreakPoints({
        x: 60,
        y: 30
      }, 'top', {
        x: 120,
        y: 70
      }, 'bottom');
      expect(br[0]).to.deep.equal({
        x: 60,
        y: 50
      });
      return expect(br[1]).to.deep.equal({
        x: 120,
        y: 50
      });
    });
    return it('should break at x and y if positions arent at direction', function() {
      return expect(rel.getBreakPoints({
        x: 20,
        y: 130
      }, 'top', {
        x: 90,
        y: 100
      }, 'left')).to.deep.equal([
        {
          x: 90,
          y: 130
        }, {
          x: 90,
          y: 130
        }
      ]);
    });
  });
});

var Relation,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Relation = (function() {

  function Relation(canvas, startTab, endTab, type) {
    this.startTab = startTab;
    this.endTab = endTab;
    this.getRelationPoints = __bind(this.getRelationPoints, this);
    this.recountPosition = __bind(this.recountPosition, this);
    this.obj = canvas.path();
    this.recountPosition();
  }

  Relation.prototype.recountPosition = function() {
    var path, points;
    points = this.getRelationPoints();
    path = ("M" + points.start.x + "," + points.start.y) + ("L" + points.break1.x + "," + points.break1.y) + ("L" + points.break2.x + "," + points.break2.y) + ("L" + points.stop.x + "," + points.stop.y);
    return this.obj.attr('path', path);
  };

  Relation.prototype.getRelationPoints = function() {
    var breaks, dist, dists, distsPoint, eCoord, ePos, eTab, result, sCoord, sPos, sTab, start, stop;
    sTab = this.startTab.getConnPoints();
    eTab = this.endTab.getConnPoints();
    dists = [];
    distsPoint = [];
    for (sPos in sTab) {
      sCoord = sTab[sPos];
      for (ePos in eTab) {
        eCoord = eTab[ePos];
        dist = this.getPathDistance(sPos, sCoord, ePos, eCoord);
        if (dist !== false) {
          dists.push(dist);
          distsPoint[dist] = [sPos, ePos];
        }
      }
    }
    if (dists.length === 0) {
      result = ['top', 'top'];
    } else {
      result = distsPoint[Math.min.apply(Math, dists)];
    }
    start = sTab[result[0]];
    stop = eTab[result[1]];
    breaks = this.getBreakPoints(start, result[0], stop, result[1]);
    return {
      start: {
        x: start.x,
        y: start.y
      },
      break1: {
        x: breaks[0].x,
        y: breaks[0].y
      },
      break2: {
        x: breaks[1].x,
        y: breaks[1].y
      },
      stop: {
        x: stop.x,
        y: stop.y
      }
    };
  };

  /**
   *
   * @param {string} pos1
   * @param {Object.<string,number>} coord1
   * @param {string} pos2
   * @param {Object.<string,number>} coord2
   * @return {number|boolean} returns number of distance, if it's possible from
   * points position else return false
  */

  Relation.prototype.getPathDistance = function(pos1, coord1, pos2, coord2) {
    if (pos1 === pos2 || (((pos1 !== 'right' && pos2 !== 'left') || coord1.x < coord2.x) && ((pos1 !== 'left' && pos2 !== 'right') || coord1.x > coord2.x) && ((pos1 !== 'bottom' && pos2 !== 'top') || coord1.y < coord2.y) && ((pos1 !== 'top' && pos2 !== 'bottom') || coord1.y > coord2.y))) {
      return Math.abs(coord1.x - coord2.x) + Math.abs(coord1.y - coord2.y);
    } else {
      return false;
    }
  };

  /**
   *
   * @param {Object.<string,number>} start Relation start point coordinates
   * @param {string} sPos Position of start relation point
   * @param {Object.<string,number>} end Relation end point coordinates
   * @param {string} ePos Position of end relation point
   * @return {Object.<string,Object>} Two relation break points
  */

  Relation.prototype.getBreakPoints = function(start, sPos, end, ePos) {
    var b1, b2, horiz, vert;
    horiz = ['left', 'right'];
    vert = ['top', 'bottom'];
    b1 = {
      x: null,
      y: null
    };
    b2 = {
      x: null,
      y: null
    };
    if (__indexOf.call(horiz, sPos) >= 0 && __indexOf.call(horiz, ePos) >= 0) {
      b1.x = b2.x = ((end.x - start.x) / 2) + start.x;
      b1.y = start.y;
      b2.y = end.y;
    } else if (__indexOf.call(vert, sPos) >= 0 && __indexOf.call(vert, ePos) >= 0) {
      b1.y = b2.y = ((end.y - start.y) / 2) + start.y;
      b1.x = start.x;
      b2.x = end.x;
    } else {
      b1.x = b2.x = end.x;
      b1.y = b2.y = start.y;
    }
    return [b1, b2];
  };

  return Relation;

})();

if (!(typeof window !== "undefined" && window !== null)) module.exports = Relation;

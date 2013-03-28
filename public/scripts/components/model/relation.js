var Relation,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Relation = (function() {

  function Relation(canvas, startTab, endTab, type) {
    this.startTab = startTab;
    this.endTab = endTab;
    this.getEndPointsCoords = __bind(this.getEndPointsCoords, this);
    this.recountPosition = __bind(this.recountPosition, this);
    this.obj = canvas.path();
    this.recountPosition();
  }

  Relation.prototype.recountPosition = function() {
    var ends, path;
    ends = this.getEndPointsCoords();
    path = "M" + ends.start.x + "," + ends.start.y + "L" + ends.stop.x + "," + ends.stop.y;
    return this.obj.attr('path', path);
  };

  Relation.prototype.getEndPointsCoords = function() {
    var dist, dists, distsPoint, eCoord, ePos, eTab, result, sCoord, sPos, sTab;
    sTab = this.startTab.getConnPoints();
    eTab = this.endTab.getConnPoints();
    dists = [];
    distsPoint = [];
    for (sPos in sTab) {
      sCoord = sTab[sPos];
      for (ePos in eTab) {
        eCoord = eTab[ePos];
        if ((sPos === ePos) || (((sPos !== 'right' && ePos !== 'left') || sCoord.x < eCoord.x) || ((sPos !== 'left' && ePos !== 'right') || sCoord.x > eCoord.x) || ((sPos !== 'bottom' && ePos !== 'top') || sCoord.y < eCoord.y) || ((sPos !== 'top' && ePos !== 'bottom') || sCoord.y > eCoord.y))) {
          dist = Math.abs(sCoord.x - eCoord.x) + Math.abs(sCoord.y - eCoord.y);
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
    return {
      start: {
        x: sTab[result[0]].x,
        y: sTab[result[0]].y
      },
      stop: {
        x: eTab[result[1]].x,
        y: eTab[result[1]].y
      }
    };
  };

  return Relation;

})();

if (!(typeof window !== "undefined" && window !== null)) module.exports = Relation;

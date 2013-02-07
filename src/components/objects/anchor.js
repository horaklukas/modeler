var Anchor,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Anchor = (function() {
  /**
   * @param canvas
   * @param {String} type One of `t`,`l`,`r`,`b` position types
   * of anchor
   * @param {Object} tabLT X and y coordinate of table left top corner 
   * @param {Object} tabRB X and y coordinate of table right bottom corner
  */
  function Anchor(canvas, type, tabLT, tabRB) {
    this.unactive = __bind(this.unactive, this);
    this.active = __bind(this.active, this);
    var x, y;
    this.start = {
      x: null,
      y: null
    };
    x = tabLT.x - 20;
    y = tabLT.y - 20;
    if (type === 't' || type === 'b') {
      x += (tabRB.x - tabLT.x) / 2 + 10;
    } else if (type === 'r') {
      x += (tabRB.x - tabLT.x) + 20;
    }
    if (type === 'l' || type === 'r') {
      y += (tabRB.y - tabLT.y) / 2 + 10;
    } else if (type === 'b') {
      y += (tabRB.y - tabLT.y) + 20;
    }
    this.obj = canvas.rect(x, y, 20, 20);
    this.obj.attr({
      fill: '#AAA',
      opacity: 0
    });
    this.obj.mouseover(this.active);
    this.obj.mouseout(this.unactive);
  }

  Anchor.prototype.active = function() {
    return this.obj.attr({
      'opacity': 0.5,
      cursor: 'crosshair'
    });
  };

  Anchor.prototype.unactive = function() {
    return this.obj.attr({
      'opacity': 0,
      cursor: 'default'
    });
  };

  return Anchor;

})();

if (!(typeof window !== "undefined" && window !== null)) module.exports = Anchor;

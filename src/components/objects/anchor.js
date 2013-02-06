var Anchor;

Anchor = (function() {
  /**
   * @param canvas
   * @param {String} type One of `t`,`l`,`r`,`b` position types
   * of anchor
   * @param {Object} tabLT X and y coordinate of table left top corner 
   * @param {Object} tabRB X and y coordinate of table right bottom corner
  */
  function Anchor(canvas, type, tabLT, tabRB) {
    var x, y;
    x = tabLT.x - 20;
    y = tabLT.y - 20;
    if (type === 't' || type === 'b') {
      x += (tabRB.x - tabLT.x) / 2;
    } else if (type === 'r') {
      x += (tabRB.x - tabLT.x) + 20;
    }
    if (type === 'l' || type === 'r') {
      y += (tabRB.y - tabLT.y) / 2;
    } else if (type === 'b') {
      y += (tabRB.y - tabLT.y) + 20;
    }
    this.obj = canvas.rect(x, y);
  }

  return Anchor;

})();

if (!(typeof window !== "undefined" && window !== null)) module.exports = Anchor;

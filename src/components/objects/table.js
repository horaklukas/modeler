var Table;

Table = (function() {

  function Table(canvas, x, y, w, h) {
    this.x = x;
    this.y = y;
    this.w = w != null ? w : 80;
    this.h = h != null ? h : 60;
    this.obj = canvas.rect(this.x, this.y, this.w, this.h, 2);
  }

  Table.prototype.show = function() {
    return this.obj.show();
  };

  Table.prototype.hide = function() {
    return this.obj.hide();
  };

  return Table;

})();

if (module) module.exports = Table;

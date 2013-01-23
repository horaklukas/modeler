var Table,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Table = (function() {

  Table.prototype.start = {
    x: [],
    y: []
  };

  function Table(canvas, x, y, w, h) {
    this.x = x;
    this.y = y;
    this.w = w != null ? w : 100;
    this.h = h != null ? h : 60;
    this.endTable = __bind(this.endTable, this);
    this.moveTable = __bind(this.moveTable, this);
    this.startTable = __bind(this.startTable, this);
    this.table = {};
    this.table.all = canvas.set();
    this.table.head = canvas.rect(this.x, this.y, this.w, 20, 2).attr({
      fill: '#AAA',
      stroke: '#000',
      opacity: 1
    });
    this.table.body = canvas.rect(this.x, this.y + 19, this.w, this.h, 2).attr({
      fill: '#EEE',
      stroke: '#000',
      opacity: 1
    });
    this.table.all.push(this.table.head, this.table.body);
    this.table.all.drag(this.moveTable, this.startTable, this.endTable);
  }

  Table.prototype.startTable = function() {
    var part, _i, _len, _ref;
    this.start.x = [];
    this.start.y = [];
    _ref = this.table.all;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      part = _ref[_i];
      this.start.x.push(part.attr('x'));
      this.start.y.push(part.attr('y'));
      console.log('start', part, this.start.x, this.start.y);
    }
    return this.table.all.attr({
      'opacity': 0.5
    });
  };

  Table.prototype.moveTable = function(dx, dy) {
    var i, part, _len, _ref;
    console.log('move ', dx, dy);
    _ref = this.table.all;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      part = _ref[i];
      console.log(this.start.x[i] + dx, this.start.y[i] + dy);
      this.table.all[i].attr({
        x: this.start.x[i] + dx,
        y: this.start.y[i] + dy
      });
    }
    return console.log('\n');
  };

  Table.prototype.endTable = function() {
    return this.table.all.attr('opacity', 1);
  };

  Table.prototype.show = function() {
    return this.table.all.show();
  };

  Table.prototype.hide = function() {
    return this.table.all.hide();
  };

  return Table;

})();

if (!(typeof window !== "undefined" && window !== null)) module.exports = Table;

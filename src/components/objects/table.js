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
    this.anchors = {};
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
    this.createAnchors(canvas);
    this.table.all.drag(this.moveTable, this.startTable, this.endTable);
  }

  Table.prototype.startTable = function() {
    var anch, k, part, _i, _len, _ref, _ref2;
    this.start.x = [];
    this.start.y = [];
    _ref = this.table.all;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      part = _ref[_i];
      this.start.x.push(part.attr('x'));
      this.start.y.push(part.attr('y'));
      console.log('start', part, this.start.x, this.start.y);
    }
    _ref2 = this.anchors;
    for (k in _ref2) {
      anch = _ref2[k];
      anch.start = anch.obj.attr(['x', 'y']);
    }
    return this.table.all.attr({
      'opacity': 0.5,
      'cursor': 'move'
    });
  };

  Table.prototype.moveTable = function(dx, dy) {
    var anch, i, k, part, _len, _ref, _ref2;
    console.log('move ', dx, dy);
    _ref = this.table.all;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      part = _ref[i];
      this.table.all[i].attr({
        x: this.start.x[i] + dx,
        y: this.start.y[i] + dy
      });
    }
    _ref2 = this.anchors;
    for (k in _ref2) {
      anch = _ref2[k];
      anch.obj.attr({
        x: anch.start.x + dx,
        y: anch.start.y + dy
      });
    }
    return console.log('\n');
  };

  Table.prototype.endTable = function() {
    this.table.all.attr('cursor', 'default');
    return this.table.all.attr('opacity', 1);
  };

  Table.prototype.createAnchors = function(canvas) {
    var lt, rb, side, _i, _len, _ref, _results;
    lt = this.table.head.attr(['x', 'y']);
    rb = {
      x: this.table.body.attr('x') + this.table.body.attr('width'),
      y: this.table.body.attr('y') + this.table.body.attr('height')
    };
    _ref = ['t', 'l', 'b', 'r'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      side = _ref[_i];
      _results.push(this.anchors[side] = new Anchor(canvas, side, lt, rb));
    }
    return _results;
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

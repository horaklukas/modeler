var Table,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Table = (function() {

  function Table(canvas, id, x, y, w, h) {
    var canvasMax, properties,
      _this = this;
    this.x = x;
    this.y = y;
    this.w = w != null ? w : 100;
    this.h = h != null ? h : 80;
    this.stopTable = __bind(this.stopTable, this);
    this.moveTable = __bind(this.moveTable, this);
    this.startTable = __bind(this.startTable, this);
    this.position = {
      current: {
        x: x,
        y: y
      },
      startmove: {
        relative: {
          x: x,
          y: y
        },
        absolute: {
          x: null,
          y: null
        }
      }
    };
    this.relations = [];
    properties = {
      width: this.w,
      height: this.h,
      left: x,
      top: y
    };
    this.table = $('<div class="table"><span class="head" ></span>').css(properties).attr('id', id);
    this.table.appendTo(canvas);
    canvasMax = {
      maxX: (typeof canvas.width === "function" ? canvas.width() : void 0) || $(canvas).width(),
      maxY: (typeof canvas.height === "function" ? canvas.height() : void 0) || $(canvas).height()
    };
    this.table.on('mousedown', function(ev) {
      _this.startTable(ev);
      $(document).on('mousemove', canvasMax, _this.moveTable);
      return $(document).one('mouseup', function() {
        $(document).off('mousemove', _this.moveTable);
        return _this.stopTable();
      });
    });
  }

  Table.prototype.startTable = function(ev) {
    var left, top, _ref;
    _ref = this.table.position(), left = _ref.left, top = _ref.top;
    this.position.current = {
      x: left,
      y: top
    };
    this.position.startmove.relative = {
      x: left,
      y: top
    };
    return this.position.startmove.absolute = {
      x: ev.pageX,
      y: ev.pageY
    };
  };

  Table.prototype.moveTable = function(ev) {
    var rel, xDiff, yDiff, _i, _len, _ref;
    this.table.addClass('move');
    xDiff = ev.pageX - this.position.startmove.absolute.x;
    yDiff = ev.pageY - this.position.startmove.absolute.y;
    this.position.current.x = this.position.startmove.relative.x + xDiff;
    this.position.current.y = this.position.startmove.relative.y + yDiff;
    if (this.position.current.x < 0) {
      this.position.current.x = 0;
    } else if (this.position.current.x > ev.data.maxX - this.w) {
      this.position.current.x = ev.data.maxX - this.w;
    }
    if (this.position.current.y < 0) {
      this.position.current.y = 0;
    } else if (this.position.current.y > ev.data.maxY - this.h) {
      this.position.current.y = ev.data.maxY - this.h;
    }
    _ref = this.relations;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      rel = _ref[_i];
      rel.recountPosition();
    }
    return this.table.css({
      'left': this.position.current.x,
      'top': this.position.current.y
    });
  };

  Table.prototype.stopTable = function() {
    return this.table.removeClass('move');
  };

  Table.prototype.getConnPoints = function() {
    return {
      top: {
        x: this.position.current.x + this.w / 2,
        y: this.position.current.y
      },
      right: {
        x: this.position.current.x + this.w + 1,
        y: this.position.current.y + this.h / 2
      },
      bottom: {
        x: this.position.current.x + this.w / 2,
        y: this.position.current.y + this.h + 1
      },
      left: {
        x: this.position.current.x,
        y: this.position.current.y + this.h / 2
      }
    };
  };

  Table.prototype.addRelation = function(rel) {
    return this.relations.push(rel);
  };

  return Table;

})();

if (!(typeof window !== "undefined" && window !== null)) module.exports = Table;

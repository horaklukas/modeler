// Generated by IcedCoffeeScript 1.4.0c
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  goog.provide('dm.model.Table');

  goog.require('tmpls.model');

  goog.require('goog.dom');

  goog.require('goog.dom.classes');

  goog.require('goog.soy');

  goog.require('goog.style');

  goog.require('goog.math.Coordinate');

  goog.require('goog.math.Size');

  dm.model.Table = (function() {

    function Table(canvas, id, x, y, w, h) {
      this.id = id;
      if (w == null) w = 100;
      if (h == null) h = 80;
      this.stopTable = __bind(this.stopTable, this);
      this.moveTable = __bind(this.moveTable, this);
      this.graspTable = __bind(this.graspTable, this);
      this.setPosition = __bind(this.setPosition, this);
      this.parentCanvas_ = canvas;
      this.columns_ = [];
      this.fkeys = [];
      this.relations_ = [];
      this.name_ = null;
      this.size_ = new goog.math.Size(w, h);
      this.position_ = null;
      this.element_ = goog.soy.renderAsElement(tmpls.model.table, {
        'id': id
      });
      goog.dom.appendChild(this.parentCanvas_, this.element_);
      this.setPosition(x, y);
      goog.events.listen(this.element_, goog.events.EventType.MOUSEDOWN, this.graspTable);
    }

    /**
     * @param {dm.ui.Canvas} canvas
     * @param {number} x
     * @param {number} y
    */


    Table.prototype.setPosition = function(x, y) {
      var canvasSize;
      canvasSize = goog.style.getSize(this.getCanvas());
      if (x + this.size_.w > canvasSize.width) {
        x = canvasSize.width - this.size_.w;
      } else if (x < 0) {
        x = 0;
      }
      if (y + this.size_.h > canvasSize.height) {
        y = canvasSize.height - this.size_.h;
      } else if (y < 0) {
        y = 0;
      }
      this.position_ = new goog.math.Coordinate(x, y);
      return goog.style.setPosition(this.element_, x, y);
    };

    /**
     * Callback that is called when user grasp table with intent to move it
     * @param {goog.events.Event} ev
    */


    Table.prototype.graspTable = function(ev) {
      var pos;
      pos = goog.style.getPosition(this.element_);
      this.position_ = new goog.math.Coordinate(pos.x, pos.y);
      this.offsetInTab = goog.style.getRelativePosition(ev, this.element_);
      goog.events.listen(document, goog.events.EventType.MOUSEMOVE, this.moveTable);
      return goog.events.listenOnce(document, goog.events.EventType.MOUSEUP, this.stopTable);
    };

    /**
     * @param {goog.events.Event} ev
    */


    Table.prototype.moveTable = function(ev) {
      var offsetInCanvas, rel, x, y, _i, _len, _ref, _results;
      goog.dom.classes.add(this.element_, 'move');
      offsetInCanvas = goog.style.getRelativePosition(ev, this.getCanvas());
      x = offsetInCanvas.x - this.offsetInTab.x;
      y = offsetInCanvas.y - this.offsetInTab.y;
      this.setPosition(x, y);
      _ref = this.relations_;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        rel = _ref[_i];
        _results.push(rel.recountPosition());
      }
      return _results;
    };

    Table.prototype.stopTable = function() {
      goog.dom.classes.remove(this.element_, 'move');
      return goog.events.unlisten(document, goog.events.EventType.MOUSEMOVE, this.moveTable);
    };

    /**
     * @return {Object.<string,goog.math.Coordinate>}
    */


    Table.prototype.getConnPoints = function() {
      return {
        top: new goog.math.Coordinate(this.position_.x + this.size_.width / 2, this.position_.y),
        right: new goog.math.Coordinate(this.position_.x + this.size_.width + 1, this.position_.y + this.size_.height / 2),
        bottom: new goog.math.Coordinate(this.position_.x + this.size_.width / 2, this.position_.y + this.size_.height + 1),
        left: new goog.math.Coordinate(this.position_.x, this.position_.y + this.size_.height / 2)
      };
    };

    /**
    	* @param {dm.model.Relation}
    */


    Table.prototype.addRelation = function(rel, child) {
      if (child == null) child = false;
      return this.relations_.push(rel);
    };

    /**
     * @param {string} name
    */


    Table.prototype.setName = function(name) {
      var tableHead;
      if (name == null) name = '';
      this.name_ = name;
      tableHead = goog.dom.getElementByClass('head', this.element_);
      return goog.dom.setTextContent(tableHead, name);
    };

    /**
     * @return {string}
    */


    Table.prototype.getName = function() {
      return this.name_;
    };

    /**
    	* Render (or rerender) table columns and recount table size
    */


    Table.prototype.render = function() {
      var tableBody;
      tableBody = goog.dom.getElementByClass('body', this.element_);
      goog.soy.renderElement(tableBody, tmpls.model.tabColumns, {
        cols: this.columns_
      });
      return this.size_ = goog.style.getSize(this.element_);
    };

    /**
    	* @param {Array.<Object>} columns List of columns with its attributes
    	* @param {boolean} rewrite Determine if columns should rewrite existing,
    	* instead of append column(s)
    */


    Table.prototype.addColumns = function(columns, rewrite) {
      if (rewrite == null) rewrite = false;
      if (rewrite === true) this.columns_ = [];
      return this.columns_ = this.columns_.concat(columns);
    };

    /**
    	* @param {Object.<string,*>} newColumn
    	* @param {boolean} isFk Wheather column is foreign key, default is false
    */


    Table.prototype.addColumn = function(newColumn, isFk) {
      if (isFk == null) isFk = false;
      this.columns_.push(newColumn);
      if (isFk) return this.fkeys.push(newColumn.name);
    };

    Table.prototype.getColumns = function() {
      return this.columns_;
    };

    /**
    	* @return {dm.ui.Canvas}
    */


    Table.prototype.getCanvas = function() {
      return this.parentCanvas_;
    };

    return Table;

  })();

  if (typeof window === "undefined" || window === null) module.exports = Table;

}).call(this);

// Generated by CoffeeScript 1.6.2
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

goog.provide('dm.ui.Canvas');

goog.provide('dm.ui.Canvas.Click');

goog.require('goog.dom');

goog.require('goog.style');

goog.require('goog.events');

goog.require('goog.events.EventTarget');

goog.require('goog.graphics');

goog.require('goog.graphics.SvgGraphics');

goog.require('goog.graphics.Stroke');

goog.require('goog.graphics.SolidFill');

goog.require('goog.graphics.Path');

dm.ui.Canvas = (function(_super) {
  __extends(Canvas, _super);

  /**
   * @constructor
   * @extends {goog.events.EventTarget}
  */


  function Canvas() {
    this.placeRelation = __bind(this.placeRelation, this);
    this.moveEndRelationPoint = __bind(this.moveEndRelationPoint, this);
    this.placeTable = __bind(this.placeTable, this);
    this.moveTable = __bind(this.moveTable, this);
    this.onClick = __bind(this.onClick, this);
    this.onDblClick = __bind(this.onDblClick, this);    Canvas.__super__.constructor.call(this);
  }

  /**
   * @param {string} canvasId Id of element to init canvas on
  */


  Canvas.prototype.init = function(canvasId) {
    var clueTabElement, fill, stroke, _ref;

    this.html = goog.dom.getElement(canvasId);
    _ref = goog.style.getSize(this.html), this.width = _ref.width, this.height = _ref.height;
    if (this.height === 0) {
      this.height = 768;
    }
    this.svg = new goog.graphics.SvgGraphics(this.width, this.height);
    this.svg.render(this.html);
    stroke = new goog.graphics.Stroke(2, '#000');
    fill = new goog.graphics.SolidFill('#CCC');
    this.clueTable = this.svg.drawRect(0, 0, 100, 80, stroke, fill);
    clueTabElement = this.clueTable.getElement();
    goog.style.setOpacity(clueTabElement, 0.5);
    goog.style.showElement(clueTabElement, false);
    goog.events.listen(this.html, goog.events.EventType.DBLCLICK, this.onDblClick);
    goog.events.listen(this.svg, goog.events.EventType.DBLCLICK, this.onDblClick);
    return goog.events.listen(this.html, goog.events.EventType.CLICK, this.onClick);
  };

  /**
   * @param {goog.events.Event} ev
  */


  Canvas.prototype.onDblClick = function(ev) {
    var table;

    table = goog.dom.getAncestorByClass(ev.target, 'table');
    if (table) {
      return this.clickedTable(table);
    } else if (ev.target.nodeName === 'path') {
      return this.clickedRelation(ev.target);
    }
  };

  /**
   * @param {goog.events.Event} ev
  */


  Canvas.prototype.onClick = function(ev) {
    var clickObj, clickPos;

    clickPos = goog.style.getRelativePosition(ev, ev.currentTarget);
    clickObj = goog.dom.getAncestorByClass(ev.target, 'table');
    return this.dispatchEvent(new dm.ui.Canvas.Click(clickPos, clickObj));
  };

  /**
   * @param {HTMLElement} table
  */


  Canvas.prototype.clickedTable = function(table) {
    var tab, tid;

    tid = table.id;
    tab = dm.actualModel.getTable(tid);
    dm.tableDialog.show(tid);
    return dm.tableDialog.setValues(tab.getName(), tab.getColumns());
  };

  Canvas.prototype.moveTable = function(ev) {
    var position;

    position = goog.style.getRelativePosition(ev, this.html);
    goog.style.showElement(this.clueTable.getElement(), true);
    return this.clueTable.setPosition(position.x, position.y);
  };

  /**
   * @param {goog.math.Coordinate} tabPos
  */


  Canvas.prototype.placeTable = function(tabPos) {
    var id;

    id = dm.actualModel.addTable(this.html, tabPos.x, tabPos.y);
    goog.style.showElement(this.clueTable.getElement(), false);
    dm.tableDialog.setValues();
    return dm.tableDialog.show(id);
  };

  /**
  	# @param {SVGPath} relation
  */


  Canvas.prototype.clickedRelation = function(relation) {
    var rel, rid;

    rid = relation.id;
    rel = dm.actualModel.getRelation(rid);
    dm.relationDialog.show(rid);
    return dm.relationDialog.setValues(rel.isIdentifying());
  };

  /**
   * @param {goog.math.Coordinate} startCoords
  */


  Canvas.prototype.setStartRelationPoint = function(startCoords) {
    var stroke;

    this.startRelationPath = new goog.graphics.Path();
    this.startRelationPath.moveTo(startCoords.x, startCoords.y);
    if (this.clueRelation) {
      goog.style.showElement(this.clueRelation.getElement(), true);
      return this.clueRelation.setPath(this.startRelationPath);
    } else {
      stroke = new goog.graphics.Stroke(1, '#000');
      this.clueRelation = this.svg.drawPath(this.startRelationPath, stroke);
      return goog.style.showElement(this.clueRelation.getElement(), true);
    }
  };

  Canvas.prototype.moveEndRelationPoint = function(ev) {
    var newPath, point;

    point = goog.style.getRelativePosition(ev, this.html);
    newPath = this.startRelationPath.clone();
    newPath.lineTo(point.x, point.y);
    return this.clueRelation.setPath(newPath);
  };

  Canvas.prototype.placeRelation = function(endCoords, startTab, endTab) {
    var id;

    goog.style.showElement(this.clueRelation.getElement(), false);
    this.startRelationPath = void 0;
    id = dm.actualModel.addRelation(this.svg, startTab, endTab);
    dm.relationDialog.setValues();
    return dm.relationDialog.show(id);
  };

  return Canvas;

})(goog.events.EventTarget);

dm.ui.Canvas.EventType = {
  CLICK: goog.events.getUniqueId('canvas-click')
};

goog.addSingletonGetter(dm.ui.Canvas);

dm.ui.Canvas.Click = (function(_super) {
  __extends(Click, _super);

  function Click(pos, obj) {
    Click.__super__.constructor.call(this, dm.ui.Canvas.EventType.CLICK, dm.ui.Canvas.getInstance());
    /**
      * @type {goog.math.Coordinate}
    */

    this.position = pos;
    /**
      * @type {?HTMLElement}
    */

    this.object = obj;
  }

  return Click;

})(goog.events.Event);

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

goog.provide('dm.ui.Table');

goog.provide('dm.ui.Table.EventType');

goog.require('tmpls.model');

goog.require('goog.dom');

goog.require('goog.dom.classes');

goog.require('goog.soy');

goog.require('goog.style');

goog.require('goog.math.Coordinate');

goog.require('goog.math.Size');

goog.require('goog.ui.Component');

goog.require('goog.events');

goog.require('goog.events.Event');

dm.ui.Table = (function(_super) {
  __extends(Table, _super);

  Table.EventType = {
    CATCH: goog.events.getUniqueId('table-catch'),
    MOVE: goog.events.getUniqueId('table-move')
  };

  /**
   * @param {dm.model.Table} tableModel
   * @param {number=} x Coordinate on x axis
   * @param {number=} y Coordinate on y axis
   * @constructor
   * @extends {goog.ui.Component}
  */


  function Table(tableModel, x, y) {
    if (x == null) {
      x = 0;
    }
    if (y == null) {
      y = 0;
    }
    this.stopTable = __bind(this.stopTable, this);
    this.moveTable = __bind(this.moveTable, this);
    this.graspTable = __bind(this.graspTable, this);
    this.setPosition = __bind(this.setPosition, this);
    this.createDom = __bind(this.createDom, this);
    Table.__super__.constructor.call(this);
    /** 
      * table's list of related relations
      * @type {Array.<dm.model.Relation>}
    */

    /**
      * @type {goog.math.Coordinate}
    */

    this.position_ = new goog.math.Coordinate(x, y);
    /**
      * @type {Element}
    */

    this.head_ = null;
    /**
      * @type {Element}
    */

    this.body_ = null;
    this.setModel(tableModel);
  }

  /**
   * @override
  */


  Table.prototype.createDom = function() {
    var element, model;

    model = this.getModel();
    element = goog.soy.renderAsElement(tmpls.model.table, {
      'id': this.getId(),
      'name': model.getName(),
      'columns': model.getColumns()
    });
    this.head_ = goog.dom.getElementByClass('head', element);
    this.body_ = goog.dom.getElementByClass('body', element);
    return this.setElementInternal(element);
  };

  /**
   * @override
  */


  Table.prototype.enterDocument = function() {
    Table.__super__.enterDocument.call(this);
    goog.style.setPosition(this.element_, this.position_.x, this.position_.y);
    return goog.events.listen(this.element_, goog.events.EventType.MOUSEDOWN, this.graspTable);
  };

  /**
   * @override
  */


  Table.prototype.setModel = function(model) {
    var _this = this;

    Table.__super__.setModel.call(this, model);
    goog.events.listen(model, 'name-change', function(ev) {
      return _this.setName(ev.target.getName());
    });
    goog.events.listen(model, 'column-change', function(ev) {
      return _this.updateColumn(ev.column.index, ev.column.data);
    });
    goog.events.listen(model, 'column-add', function(ev) {
      return _this.addColumn(ev.column.data);
    });
    return goog.events.listen(model, 'column-delete', function(ev) {
      return _this.removeColumn(ev.column.index);
    });
  };

  /**
   * @param {number} x
   * @param {number} y
  */


  Table.prototype.setPosition = function(x, y) {
    /*canvasSize = goog.style.getSize @getCanvas()
    
    		if x + @size_.w > canvasSize.width then x = canvasSize.width - @size_.w
    		else if x < 0 then x = 0
    
    		if y + @size_.h > canvasSize.height then y = canvasSize.height - @size_.h
    		else if y < 0 then y = 0
    */
    this.position_.x = x;
    this.position_.y = y;
    if (this.isInDocument()) {
      return goog.style.setPosition(this.element_, this.position_.x, this.position_.y);
    }
  };

  /**
   * Callback that is called when user grasp table with intent to move it
   * @param {goog.events.Event} ev
  */


  Table.prototype.graspTable = function(ev) {
    var offsetInTab, pos;

    if (!((this.position_.x != null) || (this.position_.y == null))) {
      pos = goog.style.getPosition(this.element_);
      this.position_.x = pos.x;
      this.position_.y = pos.y;
    }
    offsetInTab = goog.style.getRelativePosition(ev, this.element_);
    return this.dispatchEvent(new dm.ui.Table.TableCatch(offsetInTab));
  };

  /**
   * @param {goog.events.Event} ev
  */


  Table.prototype.moveTable = function(ev) {};

  Table.prototype.stopTable = function() {};

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
   * @return {goog.math.Size} table dimensions
  */


  Table.prototype.getSize = function() {
    return goog.style.getSize(this.element_);
  };

  /**
  	* @param {dm.model.Relation}
  */


  /*
  	addRelation: (rel, child = false) ->
  		@relations_.push rel
  */


  /**
   * @param {string} name Name of table
  */


  Table.prototype.setName = function(name) {
    if (name == null) {
      name = '';
    }
    return goog.dom.setTextContent(this.head_, name);
  };

  /**
  	* Adds new columns or updates existing
  	* @param {Array.<(Object,<string,*>|dm.model.TableColumn)>} columns List of
  	*  table columns at keys based object
  */


  /*
  	setColumns: (columns) ->
  		@setColumn column for column in columns
  */


  /**
   * @param {dm.model.TableColumn} column
  */


  Table.prototype.addColumn = function(column) {
    return this.body_.innerHTML += tmpls.model.tabColumn({
      col: column
    });
  };

  /**
  	* @param {number} index
  	* @param {dm.model.TableColumn} newColumn
  */


  Table.prototype.updateColumn = function(index, column) {
    var newColumn, oldColumn;

    oldColumn = goog.dom.getElementsByClass('column', this.body_)[index];
    newColumn = goog.soy.renderAsElement(tmpls.model.tabColumn, {
      col: column
    });
    return goog.dom.replaceNode(newColumn, oldColumn);
  };

  /**
   * @param {number} index
  */


  Table.prototype.removeColumn = function(index) {
    var column;

    column = goog.dom.getElementsByClass('column', this.body_)[index];
    return goog.dom.removeNode(column);
  };

  return Table;

})(goog.ui.Component);

dm.ui.Table.TableCatch = (function(_super) {
  __extends(TableCatch, _super);

  /**
   * @param {goog.math.Coordinate} tabOffset
  */


  function TableCatch(tabOffset) {
    TableCatch.__super__.constructor.call(this, dm.ui.Table.EventType.CATCH);
    /**
      * @type {goog.math.Coordinate}
    */

    this.catchOffset = tabOffset;
  }

  return TableCatch;

})(goog.events.Event);

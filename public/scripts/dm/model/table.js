var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

goog.provide('dm.model.Table');

goog.require('goog.events.EventTarget');

goog.require('goog.events.Event');

goog.require('goog.array');

/**
* @typedef {{name:string, type:string, isPk: boolean, isNotNull:boolean, isUnique:boolean}}
*/


dm.model.TableColumn;

dm.model.Table = (function(_super) {
  __extends(Table, _super);

  /**
  	* @param {string=} name
  	* @param {Array.<dm.model.TableColumn>=} columns
  	* @constructor
  	* @extends {goog.events.EventTarget}
  */


  function Table(name, columns) {
    if (name == null) {
      name = '';
    }
    if (columns == null) {
      columns = [];
    }
    Table.__super__.constructor.call(this, this);
    /** 
      * table's list of related relations
      * @type {string}
    */

    this.name_ = name;
    /**
      * @type {Array.<dm.model.TableColumn>}
    */

    this.columns_ = columns;
  }

  /**
   * @param {string} name
  */


  Table.prototype.setName = function(name) {
    if (name == null) {
      name = '';
    }
    this.name_ = name;
    return this.dispatchEvent('name-change');
  };

  /**
   * @return {string}
  */


  Table.prototype.getName = function() {
    return this.name_;
  };

  /**
  	* Adds new columns or updates existing
  	* @param {Array.<(Object,<string,*>|dm.model.TableColumnModel)>} columns List of
  	*  table columns at keys based object
  */


  /*
  	setColumns: (columns) ->
  		@setColumn column for column in columns
  */


  /**
   * @param {dm.model.TableColumn} column
  	* @param {number=} idx
  */


  Table.prototype.setColumn = function(column, idx) {
    if (idx != null) {
      this.columns_[idx] = column;
    } else {
      this.columns_.push(column);
    }
    return this.dispatchEvent(new dm.model.Table.ColumnsChange(column, idx));
  };

  /**
   * @return {Array.<dm.model.TableColumn>} table columns
  */


  Table.prototype.getColumns = function() {
    return this.columns_;
  };

  /**
   * @param {!number} idx
  */


  Table.prototype.removeColumn = function(idx) {
    goog.array.removeAt(this.columns_, idx);
    return this.dispatchEvent(new dm.model.Table.ColumnsChange(null, idx));
  };

  /**
   * @param {string=} idx
   * @return {?dm.model.TableColumn}
  */


  Table.prototype.getColumnById = function(idx) {
    var _ref;

    if (idx == null) {
      null;
    }
    return (_ref = this.columns_[idx]) != null ? _ref : null;
  };

  return Table;

})(goog.events.EventTarget);

dm.model.Table.ColumnsChange = (function(_super) {
  __extends(ColumnsChange, _super);

  /**
   * @param {?dm.model.TableColumn} column
   * @param {number=} idx
  */


  function ColumnsChange(column, idx) {
    var eventName;

    if (idx != null) {
      eventName = column != null ? 'column-change' : 'column-delete';
    } else {
      eventName = 'column-add';
    }
    ColumnsChange.__super__.constructor.call(this, eventName);
    this.column = {
      data: column,
      index: idx
    };
  }

  return ColumnsChange;

})(goog.events.Event);

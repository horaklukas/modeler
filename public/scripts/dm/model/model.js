var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

goog.provide('dm.model.Model');

goog.require('dm.model.Table');

goog.require('dm.model.Relation');

goog.require('goog.string');

goog.require('goog.ui.IdGenerator');

dm.model.Model = (function() {
  function Model(name) {
    this.addRelation = __bind(this.addRelation, this);
    this.setTable = __bind(this.setTable, this);
    this.addTable = __bind(this.addTable, this);    if (!name) {
      throw new Error('Model name must be specified!');
    }
    this.idgen_ = new goog.ui.IdGenerator();
    this.tables_ = {};
    this.relations_ = {};
  }

  /**
  	* Add table to canvas and to model's list of tables
  	*
  	* @param {Canvas} canvas Place where to create table
  	* @param {number} x Horizontal position of table on canvas
  	* @param {number} y Vertical position of table on canvas
   * @return {string} id of new table
  */


  Model.prototype.addTable = function(canvas, x, y, name) {
    var id, table;

    id = this.idgen_.getNextUniqueId();
    table = new dm.model.Table(canvas, id, x, y);
    this.tables_[id] = table;
    return id;
  };

  /**
   * Pass new values from table dialog to table
   *
   * @param {string} id Identificator of table to edit
   * @param {string} name Name of table to set
   * @param {Array.<Object.<string,*>>=} columns
  */


  Model.prototype.setTable = function(id, name, columns) {
    var table;

    table = this.getTableById(id);
    table.setName(name);
    if (columns != null) {
      table.setColumns(columns);
      return table.render();
    }
  };

  /**
   * Add relation to canvas, the add relation to list of model's relations and
   * to both table list of related relations
  */


  Model.prototype.addRelation = function(canvas, startTabId, endTabId, ident) {
    var endTab, id, newRelation, startTab;

    id = this.idgen_.getNextUniqueId();
    startTab = this.getTableById(startTabId);
    endTab = this.getTableById(endTabId);
    if ((startTab != null) && (endTab != null)) {
      newRelation = new dm.model.Relation(canvas, id, startTab, endTab, ident);
      this.relations_[id] = newRelation;
      startTab.addRelation(newRelation);
      endTab.addRelation(newRelation);
      return id;
    } else {
      return false;
    }
  };

  Model.prototype.setRelation = function(id, ident, parentTab, childTab) {
    var column, rel, _i, _len, _ref;

    rel = this.getRelationById(id);
    rel.setIdentifying(ident);
    rel.setRelatedTables(parentTab, childTab);
    _ref = parentTab.getColumns();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      column = _ref[_i];
      if (column.isPrimary() === true) {
        childTab.setColumn(column.clone());
      }
    }
    return childTab.render();
  };

  /**
  	* Returns table object by table id
   * @param {string} id
   * @return {dm.model.Table=}
  */


  Model.prototype.getTableById = function(id) {
    var _ref;

    return (_ref = this.tables_[id]) != null ? _ref : null;
  };

  /**
   * Returns relation object by relation id
   * @param {string} id
   * @return {dm.model.Relation=}
  */


  Model.prototype.getRelationById = function(id) {
    var _ref;

    return (_ref = this.relations_[id]) != null ? _ref : null;
  };

  return Model;

})();

if (typeof window === "undefined" || window === null) {
  module.exports = Model;
}

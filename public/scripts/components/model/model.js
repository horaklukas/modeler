// Generated by IcedCoffeeScript 1.4.0c
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

goog.provide('dm.components.model.Model');

goog.require('dm.components.model.Table');

goog.require('dm.components.model.Relation');

dm.components.model.Model = (function() {

  function Model(name) {
    this.addRelation = __bind(this.addRelation, this);
    this.setTable = __bind(this.setTable, this);
    this.addTable = __bind(this.addTable, this);    if (!name) throw new Error('Model name must be specified!');
    this.tables = [];
    this.relations = [];
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
    var tabId, table;
    tabId = "tab_" + this.tables.length;
    table = new dm.components.model.Table(canvas, tabId, x, y);
    this.tables.push(table);
    return tabId;
  };

  /**
   * Pass new values from table dialog to table
   *
   * @param {string} id Identificator of table to edit
   * @param {string} name Name of table to set
   * @param {Object.<string,*>=} columns
  */


  Model.prototype.setTable = function(id, name, columns) {
    var tab;
    tab = this.tables[this.getTabNumberId(id)];
    tab.setName(name);
    if (columns != null) return tab.setColumns(columns);
  };

  /**
  	* Returns table object by table id
  	*
  	* @return {Table}
  */


  Model.prototype.getTable = function(id) {
    return this.tables[this.getTabNumberId(id)];
  };

  /**
   * Add relation to canvas, the add relation to list of model's relations and
   * to both table list of related relations
  */


  Model.prototype.addRelation = function(canvas, startTabId, endTabId) {
    var endTab, newRelation, relLen, startTab;
    startTab = this.tables[this.getTabNumberId(startTabId)];
    endTab = this.tables[this.getTabNumberId(endTabId)];
    if ((startTab != null) && (endTab != null)) {
      newRelation = new dm.components.model.Relation(canvas, startTab, endTab);
      relLen = this.relations.push(newRelation);
      startTab.addRelation(this.relations[relLen - 1]);
      return endTab.addRelation(this.relations[relLen - 1]);
    } else {
      return false;
    }
  };

  Model.prototype.getTabNumberId = function(fullid) {
    var numberId;
    numberId = fullid.match(/^tab_(\d+)$/);
    if (numberId != null) {
      return Number(numberId[1]);
    } else {
      return false;
    }
  };

  return Model;

})();

if (typeof window === "undefined" || window === null) module.exports = Model;

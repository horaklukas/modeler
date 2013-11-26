// This file was automatically generated from createTable.soy.
// Please don't edit this file by hand.

goog.provide('tmpls.dialogs.createTable');

goog.require('soy');
goog.require('soydata');


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.dialogs.createTable.dialog = function(opt_data, opt_ignored) {
  return '<div id="createTable" class="dialog">' + tmpls.dialogs.createTable.name(null) + '<strong>Table columns</strong><div id="columns_list">' + tmpls.dialogs.createTable.columnsList(opt_data) + '</div><button class="add">Add new column</button></div>';
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.dialogs.createTable.name = function(opt_data, opt_ignored) {
  return '\t<div class="row"><span><label>Table name</label></span><span><input id="table_name" /></span></div>';
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.dialogs.createTable.columnsList = function(opt_data, opt_ignored) {
  var output = '<div class="row head"><span>Name</span><span>Type</span><span>PK</span><span>Not NULL</span><span>Unique</span><span></span></div>';
  if (opt_data.columns) {
    var columnList43 = opt_data.columns;
    var columnListLen43 = columnList43.length;
    for (var columnIndex43 = 0; columnIndex43 < columnListLen43; columnIndex43++) {
      var columnData43 = columnList43[columnIndex43];
      output += tmpls.dialogs.createTable.tableColumn({id: columnIndex43, name: columnData43.name, types: opt_data.types, type: columnData43.type, isPk: columnData43.isPk, isNotNull: columnData43.isNotNull, isUnique: columnData43.isUnique});
    }
  }
  output += tmpls.dialogs.createTable.tableColumn({id: opt_data.columns != null ? opt_data.columns.length : 0, types: opt_data.types});
  return output;
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.dialogs.createTable.tableColumn = function(opt_data, opt_ignored) {
  var output = '<div class="row" ' + ((opt_data.id != null) ? 'name="' + soy.$$escapeHtml(opt_data.id) + '"' : '') + ' ><span><input type="text" class="name" value="' + ((opt_data.name) ? soy.$$escapeHtml(opt_data.name) : '') + '"/></span><span><select class="type">';
  var typeeList68 = opt_data.types;
  var typeeListLen68 = typeeList68.length;
  for (var typeeIndex68 = 0; typeeIndex68 < typeeListLen68; typeeIndex68++) {
    var typeeData68 = typeeList68[typeeIndex68];
    output += '<option value="' + soy.$$escapeHtml(typeeData68) + '" ' + ((opt_data.type == typeeData68) ? 'selected' : '') + '>' + soy.$$escapeHtml(typeeData68) + '</option>';
  }
  output += '</select></span><span><input type="checkbox" class="primary" ' + ((opt_data.isPk == true) ? 'checked' : '') + ' /></span><span><input type="checkbox" class="notnull" ' + ((opt_data.isNotNull == true) ? 'checked' : '') + ' /></span><span><input type="checkbox" class="unique" ' + ((opt_data.isUnique == true) ? 'checked' : '') + ' /></span><span><button class="delete">Del</button></span></div>';
  return output;
};

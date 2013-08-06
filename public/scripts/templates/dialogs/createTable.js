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
  return '<div id="createTable" class="dialog">' + tmpls.dialogs.createTable.name(null) + '<strong>Table columns</strong>' + tmpls.dialogs.createTable.columnsList(opt_data) + '</div>';
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
  var output = '<div id="columns_list"><div class="row head"><span>Name</span><span>Type</span><span>PK</span><span>Not NULL</span><span>Unique</span><span></span></div>' + tmpls.dialogs.createTable.tableColumn(opt_data);
  if (opt_data.columns) {
    var columnList32 = opt_data.columns;
    var columnListLen32 = columnList32.length;
    for (var columnIndex32 = 0; columnIndex32 < columnListLen32; columnIndex32++) {
      var columnData32 = columnList32[columnIndex32];
      output += tmpls.dialogs.createTable.tableColumn({name: columnData32.name, types: opt_data.types, pkey: columnData32.pkey, nnull: columnData32.nnull, uniq: columnData32.uniq});
    }
  }
  output += '</div><button class="add">Add new column</button>';
  return output;
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.dialogs.createTable.tableColumn = function(opt_data, opt_ignored) {
  var output = '<div class="row"><span><input type="text" class="name" value="' + ((opt_data.name) ? soy.$$escapeHtml(opt_data.name) : '') + '"/></span><span><select class="type">';
  var typeList47 = opt_data.types;
  var typeListLen47 = typeList47.length;
  for (var typeIndex47 = 0; typeIndex47 < typeListLen47; typeIndex47++) {
    var typeData47 = typeList47[typeIndex47];
    output += '<option value="' + soy.$$escapeHtml(typeData47) + '" ' + ((opt_data.colType == typeData47) ? 'selected' : '') + '>' + soy.$$escapeHtml(typeData47) + '</option>';
  }
  output += '</select></span><span><input type="checkbox" class="pkey" ' + ((opt_data.pkey == true) ? 'checked' : '') + ' /></span><span><input type="checkbox" class="nnull" ' + ((opt_data.nnull == true) ? 'checked' : '') + ' /></span><span><input type="checkbox" class="unique" ' + ((opt_data.uniq == true) ? 'checked' : '') + ' /></span><span><button class="delete">Del</button></span></div>';
  return output;
};

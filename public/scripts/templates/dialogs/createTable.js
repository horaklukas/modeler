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
  return '<div id="createTable" class="dialog">' + tmpls.dialogs.createTable.name(null) + '<strong>Columns</strong>' + tmpls.dialogs.createTable.columnsList(opt_data) + '<button class="ok">OK</button><button class="cancel">CANCEL</button></div>';
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
  var output = '<div id="columns_list"><button>Add column</button><div class="row head"><span>Name</span><span>Type</span><span>PK</span><span></span></div>' + tmpls.dialogs.createTable.tableColumn(opt_data);
  if (opt_data.columns) {
    var columnList16 = opt_data.columns;
    var columnListLen16 = columnList16.length;
    for (var columnIndex16 = 0; columnIndex16 < columnListLen16; columnIndex16++) {
      var columnData16 = columnList16[columnIndex16];
      output += tmpls.dialogs.createTable.tableColumn({name: columnData16.name, types: opt_data.types, pkey: columnData16.pkey});
    }
  }
  output += '</div>';
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
  var typeList29 = opt_data.types;
  var typeListLen29 = typeList29.length;
  for (var typeIndex29 = 0; typeIndex29 < typeListLen29; typeIndex29++) {
    var typeData29 = typeList29[typeIndex29];
    output += '<option value="' + soy.$$escapeHtml(typeData29) + '" ' + ((opt_data.colType == typeData29) ? 'selected' : '') + '>' + soy.$$escapeHtml(typeData29) + '</option>';
  }
  output += '</select></span><span><input type="checkbox" class="pkey" ' + ((opt_data.pkey == true) ? 'checked' : '') + ' /></span><span><button class="delete">Del</button></span></div>';
  return output;
};

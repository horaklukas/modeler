// This file was automatically generated from table.soy.
// Please don't edit this file by hand.

goog.provide('tmpls.model');

goog.require('soy');
goog.require('soydata');


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.model.table = function(opt_data, opt_ignored) {
  return '<div class="table" id="' + soy.$$escapeHtml(opt_data.id) + '"><span class="head">' + soy.$$escapeHtml(opt_data.name) + '</span><div class="body">' + ((opt_data.columns) ? tmpls.model.tabColumns({cols: opt_data.columns}) : '') + '</div></div>';
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.model.tabColumns = function(opt_data, opt_ignored) {
  var output = '\t';
  var colList106 = opt_data.cols;
  var colListLen106 = colList106.length;
  for (var colIndex106 = 0; colIndex106 < colListLen106; colIndex106++) {
    var colData106 = colList106[colIndex106];
    output += tmpls.model.tabColumn({col: colData106});
  }
  return output;
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.model.tabColumn = function(opt_data, opt_ignored) {
  return '<div class="column"><span>' + soy.$$escapeHtml(opt_data.col.name) + '</span>' + ((opt_data.col.isPk) ? '<span class="idx">PK</span>' : '') + '</div>';
};

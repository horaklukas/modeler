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
  return '<div class="table" id="' + soy.$$escapeHtml(opt_data.id) + '"><span class="head"></span><div class="body"></div></div>';
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.model.tabColumns = function(opt_data, opt_ignored) {
  var output = '\t';
  var colList62 = opt_data.cols;
  var colListLen62 = colList62.length;
  for (var colIndex62 = 0; colIndex62 < colListLen62; colIndex62++) {
    var colData62 = colList62[colIndex62];
    output += tmpls.model.tabColumn({name: colData62.name, pk: colData62.pk});
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
  return '<div><span>' + soy.$$escapeHtml(opt_data.name) + '</span>' + ((opt_data.pk) ? '<span class="idx">PK</span>' : '') + '</div>';
};

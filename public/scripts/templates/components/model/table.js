// This file was automatically generated from table.soy.
// Please don't edit this file by hand.

goog.provide('tmpls.components.model');

goog.require('soy');
goog.require('soydata');


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.components.model.table = function(opt_data, opt_ignored) {
  return '<div class="table" id="' + soy.$$escapeHtml(opt_data.id) + '"><span class="head"></span><div class="body"></div></div>';
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.components.model.tabColumns = function(opt_data, opt_ignored) {
  var output = '\t';
  var colList58 = opt_data.cols;
  var colListLen58 = colList58.length;
  for (var colIndex58 = 0; colIndex58 < colListLen58; colIndex58++) {
    var colData58 = colList58[colIndex58];
    output += tmpls.components.model.tabColumn({name: colData58.name, pk: colData58.pk});
  }
  return output;
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.components.model.tabColumn = function(opt_data, opt_ignored) {
  return '<div><span>' + soy.$$escapeHtml(opt_data.name) + '</span>' + ((opt_data.pk) ? '<span class="idx">PK</span>' : '') + '</div>';
};

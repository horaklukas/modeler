// This file was automatically generated from createRelation.soy.
// Please don't edit this file by hand.

goog.provide('tmpls.dialogs.createRelation');

goog.require('soy');
goog.require('soydata');


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.dialogs.createRelation.dialog = function(opt_data, opt_ignored) {
  return '<div id="createRelation" class="dialog">' + tmpls.dialogs.createRelation.prefs(opt_data) + '</div>';
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.dialogs.createRelation.prefs = function(opt_data, opt_ignored) {
  return '<form id="relprefs">' + tmpls.dialogs.createRelation.ident({isident: opt_data.ident}) + tmpls.dialogs.createRelation.selectParent({parent: opt_data.parentTable, child: opt_data.childTable}) + '</form>';
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.dialogs.createRelation.ident = function(opt_data, opt_ignored) {
  return '\t<div>Relation type</div><input type="radio" name="ident" value="0" ' + ((! opt_data.isident) ? 'checked' : '') + '>Non-Identifying relation<br /><input type="radio" name="ident" value="1" ' + ((opt_data.isident) ? 'checked' : '') + '>Identifying relation';
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.dialogs.createRelation.selectParent = function(opt_data, opt_ignored) {
  return '<div><p><span>Parent table:</span> <strong class="parent" >' + soy.$$escapeHtml(opt_data.parent) + '</strong></p><button id="swaptables">Swap tables</button><p><span>Child table:</span> <strong class="child">' + soy.$$escapeHtml(opt_data.child) + '</strong></p></div>';
};

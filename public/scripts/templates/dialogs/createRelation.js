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
  return '<div id="createRelation" class="dialog">' + tmpls.dialogs.createRelation.identform({isident: opt_data.ident}) + '</div>';
};


/**
 * @param {Object.<string, *>=} opt_data
 * @param {(null|undefined)=} opt_ignored
 * @return {string}
 * @notypecheck
 */
tmpls.dialogs.createRelation.identform = function(opt_data, opt_ignored) {
  return '<form id="reltype"><input type="radio" name="ident" value="0" ' + ((! opt_data.isident) ? 'checked' : '') + '>Non-Identifying relation<input type="radio" name="ident" value="1" ' + ((opt_data.isident) ? 'checked' : '') + '>Identifying relation</form>';
};

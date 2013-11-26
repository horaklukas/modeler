var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

goog.provide('dm.dialogs.RelationDialog');

goog.provide('dm.dialogs.RelationDialog.Confirm');

goog.require('goog.ui.Dialog');

goog.require('tmpls.dialogs.createRelation');

goog.require('goog.dom');

goog.require('goog.soy');

goog.require('goog.string');

goog.require('goog.events');

dm.dialogs.RelationDialog = (function(_super) {
  __extends(RelationDialog, _super);

  RelationDialog.EventType = {
    CONFIRM: goog.events.getUniqueId('dialog-confirmed')
  };

  function RelationDialog() {
    this.onSelect = __bind(this.onSelect, this);
    this.swapTables = __bind(this.swapTables, this);
    this.setIdentifying = __bind(this.setIdentifying, this);
    var content;

    RelationDialog.__super__.constructor.call(this);
    this.isIdentifying = false;
    this.tablesSwaped = false;
    this.setContent(tmpls.dialogs.createRelation.dialog(false));
    this.setButtonSet(goog.ui.Dialog.ButtonSet.OK_CANCEL);
    this.setDraggable(false);
    content = this.getContentElement();
    this.relPrefsForm = goog.dom.getElement('relprefs');
    goog.events.listen(this.relPrefsForm, goog.events.EventType.CHANGE, this.setIdentifying);
    goog.events.listen(this.relPrefsForm, goog.events.EventType.SUBMIT, this.swapTables);
    goog.events.listen(this, goog.ui.Dialog.EventType.SELECT, this.onSelect);
  }

  /**
  	* If change type of relation (identifying or non-identifying) then save
  	* actual value 
   * @param {goog.events.Event} ev
  */


  RelationDialog.prototype.setIdentifying = function(ev) {
    return this.isIdentifying = Boolean(goog.string.toNumber(ev.target.value));
  };

  /**
   * @param {goog.events.Event} ev
  */


  RelationDialog.prototype.swapTables = function(ev) {
    var child, parent, tmp;

    this.tablesSwaped = !this.tablesSwaped;
    parent = goog.dom.getElementByClass('parent', ev.target);
    child = goog.dom.getElementByClass('child', ev.target);
    tmp = goog.dom.getTextContent(parent);
    goog.dom.setTextContent(parent, goog.dom.getTextContent(child));
    goog.dom.setTextContent(child, tmp);
    return ev.preventDefault();
  };

  /**
   * @param {boolean} show Wheater show or hide dialog
   * @param {dm.ui.Relation=} relation
  */


  RelationDialog.prototype.show = function(show, relation) {
    if (relation != null) {
      this.relatedRelation = relation;
      this.isIdentifying = relation.getModel().isIdentifying();
      this.setValues(relation.parentTab.getModel().getName(), relation.childTab.getModel().getName(), this.isIdentifying);
    }
    return this.setVisible(show);
  };

  RelationDialog.prototype.onSelect = function(e) {
    if (e.key !== 'ok') {
      return true;
    }
  };

  /**
  	* @param {string} parent Parent table name
  	* @param {string} child Child table name
  	* @param {boolean} ident
  */


  RelationDialog.prototype.setValues = function(parent, child, ident) {
    return goog.soy.renderElement(this.relPrefsForm, tmpls.dialogs.createRelation.prefs, {
      ident: ident,
      parentTable: parent,
      childTable: child
    });
  };

  return RelationDialog;

})(goog.ui.Dialog);

goog.addSingletonGetter(dm.dialogs.RelationDialog);

/**
* @type {string}
*/


/**
* @type {boolean}
*/


/**
* @type {string}
*/


/**
* @type {string}
*/


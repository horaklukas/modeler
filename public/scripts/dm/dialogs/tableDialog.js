var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

goog.provide('dm.dialogs.TableDialog');

goog.provide('dm.dialogs.TableDialog.Confirm');

goog.require('goog.ui.Dialog');

goog.require('tmpls.dialogs.createTable');

goog.require('goog.dom');

goog.require('goog.dom.classes');

goog.require('goog.dom.query');

goog.require('goog.soy');

goog.require('goog.events');

goog.require('goog.array');

goog.require('goog.object');

goog.require('goog.string');

dm.dialogs.TableDialog = (function(_super) {
  __extends(TableDialog, _super);

  TableDialog.EventType = {
    CONFIRM: goog.events.getUniqueId('dialog-confirmed')
  };

  function TableDialog() {
    this.onSelect = __bind(this.onSelect, this);
    this.removeColumn = __bind(this.removeColumn, this);
    this.addColumn = __bind(this.addColumn, this);
    var addBtn, content,
      _this = this;

    TableDialog.__super__.constructor.call(this);
    this.setContent(tmpls.dialogs.createTable.dialog({
      types: DB.types
    }));
    this.setButtonSet(goog.ui.Dialog.ButtonSet.OK_CANCEL);
    this.setDraggable(false);
    content = this.getContentElement();
    addBtn = goog.dom.getElementsByTagNameAndClass('button', 'add', content)[0];
    this.nameField = goog.dom.getElement('table_name');
    this.colslist = goog.dom.getElement('columns_list');
    this.columns_ = {
      removed: null,
      added: null,
      updated: null,
      count: 0
    };
    goog.events.listen(addBtn, goog.events.EventType.CLICK, this.addColumn);
    goog.events.listen(this.colslist, goog.events.EventType.CLICK, function(e) {
      if (goog.dom.classes.has(e.target, 'delete')) {
        return _this.removeColumn(e.target);
      }
    });
    goog.events.listen(this, goog.ui.Dialog.EventType.SELECT, this.onSelect);
  }

  /** @override
  */


  /**
  	* Show the dialog window
  	* @param {boolean} show 
  	* @param {dm.ui.Table=} table
  */


  TableDialog.prototype.show = function(show, table) {
    var columns, i, model, row, rows, _i, _ref,
      _this = this;

    if (table != null) {
      this.table_ = table;
      model = table.getModel();
      columns = model.getColumns();
      this.columns_ = {
        removed: [],
        updated: [],
        added: [columns.length],
        count: columns.length
      };
      this.setValues(model.getName(), columns);
      rows = goog.dom.getChildren(this.colslist);
      for (i = _i = 1, _ref = rows.length - 2; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        row = rows[i];
        goog.events.listen(row, goog.events.EventType.CHANGE, function(e) {
          var columnRow, index;

          columnRow = goog.dom.getAncestorByClass(e.target, 'row');
          index = goog.string.toNumber(columnRow.getAttribute('name'));
          if (__indexOf.call(_this.columns_.updated, index) < 0) {
            return _this.columns_.updated.push(index);
          }
        });
      }
    }
    return this.setVisible(show);
  };

  /**
  	* @param {number} index Column index
   * @return {dm.model.TableColumn} model of columns with passed index
  */


  TableDialog.prototype.getColumnModel = function(index) {
    var column;

    column = goog.dom.query("*[name='" + index + "']", this.colslist);
    if (column.length === 0) {
      throw new Error('Column not exist!');
    }
    column = column[0];
    return {
      name: goog.dom.getElementByClass('name', column).value,
      type: goog.dom.getElementByClass('type', column).value,
      isPk: goog.dom.getElementByClass('primary', column).checked,
      isNotNull: goog.dom.getElementByClass('notnull', column).checked,
      isUnique: goog.dom.getElementByClass('unique', column).checked
    };
  };

  /**
  	* Return table name, filled in dialog
  	* @return {string} Table name
  */


  TableDialog.prototype.getName = function() {
    return this.nameField.value;
  };

  /**
  	* Set table values (name and columns) to dialog, used when editing table
  	*
  	* @param {string=} name
  	* @param {Array.<dm.model.Table>=} cols
  */


  TableDialog.prototype.setValues = function(name, cols) {
    if (name == null) {
      name = '';
    }
    if (cols == null) {
      cols = [];
    }
    goog.dom.setProperties(this.nameField, {
      'value': name
    });
    return this.colslist.innerHTML = tmpls.dialogs.createTable.columnsList({
      types: DB.types,
      columns: cols
    });
  };

  /**
  	* Add new `column` row to dialog, empty or set in depend if values are passed
  	*
  	* @param {dm.model.TableColumn} column
  */


  TableDialog.prototype.addColumn = function(column) {
    var opts;

    opts = {
      types: DB.types
    };
    this.columns_.count++;
    opts.id = this.columns_.count;
    /*
    		if column?
    			if goog.isString(column.name) then opts.name = column.name
    			if goog.isString(column.type) then opts.type = column.type
    			if column.isPk? then opts.isPk = column.isPk
    			if column.isNotNull? then opts.isNotNull = column.isNotNull
    			if column.isUnique? then opts.isUnique = column.isUnique
    */

    this.colslist.innerHTML += tmpls.dialogs.createTable.tableColumn(opts);
    return this.columns_.added.push(this.columns_.count);
  };

  /**
   * @param {Element} deleteBtn Button element that invoked action
  */


  TableDialog.prototype.removeColumn = function(deleteBtn) {
    var columnRow, index;

    columnRow = goog.dom.getAncestorByClass(deleteBtn, 'row');
    index = goog.string.toNumber(columnRow.getAttribute('name'));
    if (__indexOf.call(this.columns_.added, index) >= 0) {
      goog.array.remove(this.columns_.added, index);
    } else {
      this.columns_.removed.push(index);
    }
    return goog.dom.removeNode(columnRow);
  };

  /**
   * @param {goog.events.Event} e
  */


  TableDialog.prototype.onSelect = function(e) {
    var colmodel, id, model, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _results;

    if (e.key !== 'ok') {
      return true;
    }
    model = this.table_.getModel();
    model.setName(this.getName());
    _ref = this.columns_.updated;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      id = _ref[_i];
      model.setColumn(this.getColumnModel(id), id);
    }
    _ref1 = this.columns_.removed;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      id = _ref1[_j];
      model.removeColumn(id);
    }
    _ref2 = this.columns_.added;
    _results = [];
    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
      id = _ref2[_k];
      colmodel = this.getColumnModel(id);
      if ((colmodel.name != null) && colmodel.name !== '') {
        _results.push(model.setColumn(colmodel));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  return TableDialog;

})(goog.ui.Dialog);

goog.addSingletonGetter(dm.dialogs.TableDialog);

/*
class dm.dialogs.TableDialog.Confirm extends goog.events.Event
	constructor: (dialog, id, name, columns) ->
		super dm.dialogs.TableDialog.EventType.CONFIRM, dialog
*/


/**
* @type {string}
*/


/**
* @type {string}
*/


/**
* @type {Array.<Object>}
*/


// Generated by CoffeeScript 1.6.2
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

goog.provide('dm.dialogs.TableDialog');

goog.provide('dm.dialogs.TableDialog.Confirm');

goog.require('goog.ui.Dialog');

goog.require('tmpls.dialogs.createTable');

goog.require('goog.dom');

goog.require('goog.dom.classes');

goog.require('goog.soy');

goog.require('goog.events');

goog.require('goog.array');

dm.dialogs.TableDialog = (function(_super) {
  __extends(TableDialog, _super);

  function TableDialog(types) {
    var addBtn, content,
      _this = this;

    this.types = types;
    this.onSelect = __bind(this.onSelect, this);
    this.removeColumn = __bind(this.removeColumn, this);
    this.addColumn = __bind(this.addColumn, this);
    TableDialog.__super__.constructor.call(this);
    this.setContent(tmpls.dialogs.createTable.dialog({
      types: types
    }));
    this.setButtonSet(goog.ui.Dialog.ButtonSet.OK_CANCEL);
    this.setDraggable(false);
    content = this.getContentElement();
    addBtn = goog.dom.getElementsByTagNameAndClass('button', 'add', content)[0];
    this.nameField = goog.dom.getElement('table_name');
    this.colslist = goog.dom.getElement('columns_list');
    goog.events.listen(addBtn, goog.events.EventType.CLICK, this.addColumn);
    goog.events.listen(this.colslist, goog.events.EventType.CLICK, function(e) {
      if (goog.dom.classes.has(e.target, 'delete')) {
        return _this.removeColumn(e.target);
      }
    });
    goog.events.listen(this, goog.ui.Dialog.EventType.SELECT, this.onSelect);
  }

  /**
  	* Show the dialog window
  */


  TableDialog.prototype.show = function(table) {
    this.relatedTable = table;
    this.columnsCount = 0;
    return this.setVisible(true);
  };

  /**
  	* Return all `columns` in dialog that have filled name, columns with empty
  	* name are skipped
  	*
  	* @return {Array.<Object>} List of columns's objects, each object has
  	* property `name`, `type` and `pk`
  */


  TableDialog.prototype.getColumns = function() {
    var cols, colsValues;

    cols = goog.dom.getElementsByTagNameAndClass(void 0, 'row', this.colslist);
    colsValues = goog.array.map(cols, function(elem) {
      var name, nnull, pkey, type, uniq;

      if (goog.dom.classes.has(elem, 'head')) {
        return null;
      }
      name = goog.dom.getElementsByTagNameAndClass(void 0, 'name', elem)[0];
      if ((name.value == null) || name.value === '') {
        return null;
      }
      type = goog.dom.getElementsByTagNameAndClass(void 0, 'type', elem)[0];
      pkey = goog.dom.getElementsByTagNameAndClass(void 0, 'pkey', elem)[0];
      nnull = goog.dom.getElementsByTagNameAndClass(void 0, 'nnull', elem)[0];
      uniq = goog.dom.getElementsByTagNameAndClass(void 0, 'unique', elem)[0];
      return {
        name: name.value,
        type: type.value,
        pk: pkey.checked,
        nnull: nnull.checked,
        uniq: uniq.checked
      };
    });
    return goog.array.filter(colsValues, function(elem) {
      return elem != null;
    });
  };

  /**
  	* Return table name, filled in dialog
  	*
  	* @return {string} Table name
  */


  TableDialog.prototype.getName = function() {
    return this.nameField.value;
  };

  /**
  	* Set table values (name and columns) to dialog, used when editing table
  	*
  	* @param {string=} name
  	* @param {Array.<Object>=} cols
  */


  TableDialog.prototype.setValues = function(name, cols) {
    var col, cols2set, oldcol, oldcols, _i, _j, _len, _len1, _ref, _results;

    if (name == null) {
      name = '';
    }
    if (cols == null) {
      cols = [];
    }
    goog.dom.setProperties(this.nameField, {
      'value': name
    });
    cols2set = cols.concat([
      {
        name: '',
        type: null,
        pk: false,
        nnull: false,
        uniq: false
      }
    ]);
    oldcols = goog.dom.getElementsByTagNameAndClass(void 0, 'row', this.colslist);
    _ref = goog.array.slice(oldcols, 1);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      oldcol = _ref[_i];
      goog.dom.removeNode(oldcol);
    }
    _results = [];
    for (_j = 0, _len1 = cols2set.length; _j < _len1; _j++) {
      col = cols2set[_j];
      _results.push(this.addColumn(col.name, col.type, col.pk, col.nnull, col.uniq));
    }
    return _results;
  };

  /**
  	* Add new `column` row to dialog, empty or set in depend if values are passed
  	*
  	* @param {string=} name
  	* @param {string=} type
  	* @param {boolean=} pk
  	* @param {boolean=} nnull
  	* @param {boolean=} uniq
  */


  TableDialog.prototype.addColumn = function(name, type, pk, nnull, uniq) {
    var col, opts;

    opts = {
      types: this.types
    };
    if ((name != null) && typeof name === 'string') {
      opts.name = name;
    }
    if ((type != null) && typeof type === 'string') {
      opts.colType = type;
    }
    if (pk != null) {
      opts.pkey = pk;
    }
    if (nnull != null) {
      opts.nnull = nnull;
    }
    if (uniq != null) {
      opts.uniq = uniq;
    }
    col = goog.soy.renderAsElement(tmpls.dialogs.createTable.tableColumn, opts);
    goog.dom.appendChild(this.colslist, col);
    return this.columnsCount++;
  };

  TableDialog.prototype.removeColumn = function(deleteBtn) {
    var columnRow;

    columnRow = goog.dom.getAncestorByClass(deleteBtn, 'row');
    if (this.columnsCount === 1) {
      this.addColumn();
    }
    goog.dom.removeNode(columnRow);
    return this.columnsCount--;
  };

  TableDialog.prototype.onSelect = function(e) {
    var columns, confirmEvent, tabName;

    if (e.key !== 'ok') {
      return true;
    }
    tabName = this.getName();
    columns = this.getColumns();
    confirmEvent = new dm.dialogs.TableDialog.Confirm(this, this.relatedTable, tabName, columns);
    return this.dispatchEvent(confirmEvent);
  };

  return TableDialog;

})(goog.ui.Dialog);

dm.dialogs.TableDialog.EventType = {
  CONFIRM: goog.events.getUniqueId('dialog-confirmed')
};

dm.dialogs.TableDialog.Confirm = (function(_super) {
  __extends(Confirm, _super);

  function Confirm(dialog, id, name, columns) {
    Confirm.__super__.constructor.call(this, dm.dialogs.TableDialog.EventType.CONFIRM, dialog);
    /**
      * @type {string}
    */

    this.tableId = id;
    /**
      * @type {string}
    */

    this.tableName = name;
    /**
      * @type {Array.<Object>}
    */

    this.tableColumns = columns;
  }

  return Confirm;

})(goog.events.Event);

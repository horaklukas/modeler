var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

goog.provide('dm.ui.Toolbar');

goog.provide('dm.ui.tools.CreateTable');

goog.provide('dm.ui.tools.createRelation');

goog.require('dm.ui.Canvas');

goog.require('dm.dialogs.TableDialog');

goog.require('goog.dom');

goog.require('goog.dom.classes');

goog.require('goog.events');

goog.require('goog.events.EventType');

goog.require('goog.events.EventTarget');

goog.require('goog.style');

goog.require('goog.ui.Component.State');

goog.require('goog.ui.Component.EventType');

goog.require('goog.ui.Toolbar');

goog.require('goog.ui.ToolbarToggleButton');

goog.require('goog.ui.SelectionModel');

dm.ui.Toolbar = (function(_super) {
  __extends(Toolbar, _super);

  /**
   * @constructor
   * @extends {goog.ui.Toolbar}
  */


  function Toolbar() {
    Toolbar.__super__.constructor.call(this);
    this.selectionModel_ = new goog.ui.SelectionModel();
    this.selectionModel_.setSelectionHandler(this.onSelect);
  }

  /** @override
  */


  Toolbar.prototype.createDom = function() {
    Toolbar.__super__.createDom.call(this);
    this.addChild(new dm.ui.tools.CreateTable(), true);
    return this.addChild(new dm.ui.tools.CreateRelation(), true);
  };

  /** @override
  */


  Toolbar.prototype.enterDocument = function() {
    var canvas,
      _this = this;

    Toolbar.__super__.enterDocument.call(this);
    canvas = dm.ui.Canvas.getInstance();
    this.selectionModel_.addItem(this.getChildAt(0));
    this.selectionModel_.addItem(this.getChildAt(1));
    goog.events.listen(this, goog.ui.Component.EventType.ACTION, function(e) {
      return _this.selectionModel_.setSelectedItem(e.target);
    });
    return goog.events.listen(canvas, dm.ui.Canvas.EventType.CLICK, function(ev) {
      var selectedButton;

      selectedButton = _this.selectionModel_.getSelectedItem();
      if (!selectedButton) {
        return false;
      }
      selectedButton.setActionEvent(ev);
      return _this.selectionModel_.setSelectedItem();
    });
  };

  /**
   * @param {goog.ui.Button} button
   * @param {boolean} select
  */


  Toolbar.prototype.onSelect = function(button, select) {
    if (button) {
      button.setChecked(select);
    }
    if (select === true) {
      return button.startAction();
    } else if (select === false) {
      return button.finishAction();
    }
  };

  return Toolbar;

})(goog.ui.Toolbar);

dm.ui.tools.CreateToggleButton = (function(_super) {
  __extends(CreateToggleButton, _super);

  /**
   * @constructor
   * @extends {goog.ui.ToolbarToggleButton}
  */


  function CreateToggleButton(name) {
    CreateToggleButton.__super__.constructor.call(this, goog.dom.createDom('div', "icon tool create-" + name));
    this.setAutoStates(goog.ui.Component.State.CHECKED, false);
  }

  /**
   * @param {dm.ui.Canvas.Click} ev Click on canvas event
  */


  CreateToggleButton.prototype.setActionEvent = function(ev) {
    return this.actionEvent = ev;
  };

  return CreateToggleButton;

})(goog.ui.ToolbarToggleButton);

dm.ui.tools.CreateTable = (function(_super) {
  __extends(CreateTable, _super);

  /**
   * @constructor
   * @extends {dm.ui.tools.CreateToggleButton}
  */


  function CreateTable() {
    this.finishAction = __bind(this.finishAction, this);    CreateTable.__super__.constructor.call(this, 'table');
    /**
      * @type {?goog.events.Event}
    */

    this.actionEvent = null;
  }

  /**
   * Called by toolbar when tool is selected
  */


  CreateTable.prototype.startAction = function() {
    var canvas;

    canvas = dm.ui.Canvas.getInstance();
    goog.style.showElement(canvas.clueTable, true);
    canvas.move = {
      offset: new goog.math.Coordinate(0, 0),
      object: canvas.clueTable
    };
    goog.style.setPosition(canvas.clueTable, 0, 0);
    return goog.events.listen(document, goog.events.EventType.MOUSEMOVE, canvas.moveTable);
  };

  /**
  */


  CreateTable.prototype.finishAction = function(ev) {
    var canvas, tab;

    canvas = dm.ui.Canvas.getInstance();
    goog.style.showElement(canvas.clueTable, false);
    goog.events.unlisten(document, goog.events.EventType.MOUSEMOVE, canvas.moveTable);
    if (this.actionEvent != null) {
      tab = new dm.ui.Table(new dm.model.Table(), this.actionEvent.position.x, this.actionEvent.position.y);
      canvas.addChild(tab, true);
    }
    if (tab != null) {
      dm.dialogs.TableDialog.getInstance().show(true, tab);
    }
    return this.actionEvent = null;
  };

  return CreateTable;

})(dm.ui.tools.CreateToggleButton);

dm.ui.tools.CreateRelation = (function(_super) {
  __extends(CreateRelation, _super);

  /**
   * @constructor
   * @extends {dm.ui.tools.CreateToggleButton}
  */


  function CreateRelation() {
    CreateRelation.__super__.constructor.call(this, 'relation');
  }

  CreateRelation.prototype.startAction = function() {
    var canvas;

    canvas = dm.ui.Canvas.getInstance();
    return canvas.html.style.cursor = 'crosshair';
  };

  /**
   * @param {goog.math.Coordinate=} position
   * @param {?HTMLElement} object
  */


  CreateRelation.prototype.finishAction = function(position, object) {
    var canvas, mousemove;

    if (!position) {
      return true;
    }
    if (!object) {
      return false;
    }
    canvas = dm.ui.Canvas.getInstance();
    mousemove = goog.events.EventType.MOUSEMOVE;
    if (!canvas.startRelationPath) {
      this.startTabId = object.id;
      canvas.setStartRelationPoint(position);
      goog.events.listen(canvas.html, mousemove, canvas.moveEndRelationPoint);
      return false;
    } else {
      canvas.placeRelation(position, this.startTabId, object.id);
      goog.events.unlisten(canvas.html, mousemove, canvas.moveEndRelationPoint);
      canvas.html.style.cursor = 'default';
      return true;
    }
  };

  return CreateRelation;

})(dm.ui.tools.CreateToggleButton);

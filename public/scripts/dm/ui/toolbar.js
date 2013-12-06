var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

goog.provide('dm.ui.Toolbar');

goog.provide('dm.ui.Toolbar.EventType');

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

  Toolbar.EventType = {
    CREATE: goog.events.getUniqueId('object-created')
  };

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
      if (selectedButton.setActionEvent(ev)) {
        return _this.selectionModel_.setSelectedItem();
      }
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
    /**
      * @type {?goog.events.Event}
    */

    this.actionEvent = null;
  }

  /**
   * @param {dm.ui.Canvas.Click} ev Click on canvas event
   * @return {boolean} true if setting action succeded
  */


  CreateToggleButton.prototype.setActionEvent = function(ev) {
    this.actionEvent = ev;
    return true;
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
    var canvas;

    canvas = dm.ui.Canvas.getInstance();
    goog.style.showElement(canvas.clueTable, false);
    goog.events.unlisten(document, goog.events.EventType.MOUSEMOVE, canvas.moveTable);
    if (this.actionEvent != null) {
      this.dispatchEvent(new dm.ui.Toolbar.ObjectCreate('table', this.actionEvent.position));
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
    /**
      * @type {dm.ui.Table}
    */

    this.parentTable = null;
    /**
      * @type {dm.ui.Table}
    */

    this.childTable = null;
  }

  CreateRelation.prototype.startAction = function() {
    var canvas;

    return canvas = dm.ui.Canvas.getInstance();
  };

  /**
   * @param {dm.ui.Canvas.Click} ev Click on canvas event
  */


  CreateRelation.prototype.setActionEvent = function(ev) {
    var obj;

    obj = ev.target;
    if (obj instanceof dm.ui.Table) {
      goog.dom.classes.add(obj.getElement(), 'active');
      if (this.parentTable == null) {
        this.parentTable = obj;
      } else if (!this.childTable) {
        this.childTable = obj;
        return true;
      }
    }
    return false;
  };

  /**
   * @param {goog.math.Coordinate=} position
   * @param {?HTMLElement} object
  */


  CreateRelation.prototype.finishAction = function(position, object) {
    if (!(this.parentTable && this.childTable)) {
      return false;
    }
    goog.dom.classes.remove(this.parentTable.getElement(), 'active');
    goog.dom.classes.remove(this.childTable.getElement(), 'active');
    this.dispatchEvent(new dm.ui.Toolbar.ObjectCreate('relation', {
      parent: this.parentTable,
      child: this.childTable
    }));
    this.parentTable = null;
    return this.childTable = null;
    /*
    		unless position then return true 
    		unless object then return false
    
    		canvas = dm.ui.Canvas.getInstance()
    		mousemove = goog.events.EventType.MOUSEMOVE
    
    		# Create clue relation or only set start point to existing
    		unless canvas.startRelationPath
    			@startTabId = object.id
    			canvas.setStartRelationPoint position
    			goog.events.listen canvas.html, mousemove, canvas.moveEndRelationPoint
    
    			return false
    		else
    			canvas.placeRelation position, @startTabId, object.id
    			goog.events.unlisten canvas.html, mousemove, canvas.moveEndRelationPoint
    
    			canvas.html.style.cursor = 'default'
    			return true
    */

  };

  return CreateRelation;

})(dm.ui.tools.CreateToggleButton);

dm.ui.Toolbar.ObjectCreate = (function(_super) {
  __extends(ObjectCreate, _super);

  /**
   * @param {(goog.math.Coordinate|*)} data Position in canvas where to create
   *  or any other data associated with creation process
   * @constructor
   * @extends {goog.events.Event}
  */


  function ObjectCreate(objType, data) {
    this.objType = objType;
    this.data = data;
    ObjectCreate.__super__.constructor.call(this, dm.ui.Toolbar.EventType.CREATE);
  }

  return ObjectCreate;

})(goog.events.Event);

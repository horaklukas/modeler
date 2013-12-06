var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

goog.provide('dm.ui.Canvas');

goog.provide('dm.ui.Canvas.Click');

goog.require('goog.dom');

goog.require('goog.style');

goog.require('goog.events');

goog.require('goog.graphics');

goog.require('goog.graphics.SvgGraphics');

goog.require('goog.graphics.Stroke');

goog.require('goog.graphics.SolidFill');

goog.require('goog.graphics.Path');

goog.require('dm.ui.Table.EventType');

dm.ui.Canvas = (function(_super) {
  __extends(Canvas, _super);

  Canvas.EventType = {
    OBJECT_EDIT: goog.events.getUniqueId('object-edit'),
    CLICK: goog.events.getUniqueId('click')
  };

  /**
   * @constructor
   * @extends {goog.events.EventTarget}
  */


  function Canvas() {
    this.getObjectIdByElement = __bind(this.getObjectIdByElement, this);
    this.addRelation = __bind(this.addRelation, this);
    this.addTableInternal_ = __bind(this.addTableInternal_, this);
    this.addTable = __bind(this.addTable, this);
    this.moveTable = __bind(this.moveTable, this);
    this.onClick = __bind(this.onClick, this);
    this.onDblClick = __bind(this.onDblClick, this);    Canvas.__super__.constructor.call(this, '100%', '100%');
    /**
      * @typedef {{object:(dm.ui.Table|dm.ui.Relation),offset:goog.math.Coordinate}}
    */

    this.move = {
      object: null,
      offset: null
    };
    /**
      * @type {goog.math.Coordinate}
    */

    this.size_ = null;
    /**
      * @type {Element}
    */

    this.rootElement_ = null;
  }

  /**
   * @override
  */


  /**
   * @override
  */


  Canvas.prototype.enterDocument = function() {
    Canvas.__super__.enterDocument.call(this);
    this.rootElement_ = goog.dom.getParentElement(this.getElement());
    this.size_ = goog.style.getSize(this.rootElement_);
    goog.events.listen(this.rootElement_, goog.events.EventType.DBLCLICK, this.onDblClick);
    goog.events.listen(this.rootElement_, goog.events.EventType.CLICK, this.onClick);
    goog.events.listen(this, dm.ui.Table.EventType.CATCH, this.onCaughtTable);
    this.clueTable = goog.dom.createDom('div', 'table');
    goog.style.setStyle(this.clueTable, {
      opacity: 0.5,
      'background-color': 'grey',
      width: 80,
      height: 100,
      top: 0,
      left: 0,
      display: 'none'
    });
    return this.addTableInternal_(this.clueTable);
  };

  /**
   * @param {string} canvasId Id of element to init canvas on
  */


  Canvas.prototype.init = function(canvasId) {
    /*
    		@html = goog.dom.getElement canvasId
    
    		{@width, @height} = goog.style.getSize @html
    		# @FIXME - remove this row and set height from document viewport height 
    		if @height is 0 then @height = 768
    		
    		@svg = new goog.graphics.SvgGraphics @width, @height
    		@svg.render @html
    
    		stroke = new goog.graphics.Stroke 2, '#000'
    		fill = new goog.graphics.SolidFill '#CCC'
    		@clueTable = @svg.drawRect 0, 0, 100, 80, stroke, fill
    
    		clueTabElement = @clueTable.getElement()
    		goog.style.setOpacity clueTabElement, 0.5
    		goog.style.showElement clueTabElement, false 
    
    		
    		goog.events.listen @html, goog.events.EventType.DBLCLICK, @onDblClick
    		goog.events.listen @svg, goog.events.EventType.DBLCLICK, @onDblClick
    		goog.events.listen @html, goog.events.EventType.CLICK, @onClick
    */

  };

  /**
   * @param {goog.events.Event} ev
  */


  Canvas.prototype.onDblClick = function(ev) {
    var object;

    if (ev.target === this.rootElement_) {
      return false;
    }
    object = this.getChild(this.getObjectIdByElement(ev.target));
    return this.dispatchEvent(new dm.ui.Canvas.EditObject(object));
    /*
    		if table then @clickedTable table
    		else if ev.target.nodeName is 'path' then @clickedRelation ev.target
    */

  };

  /**
   * @param {goog.events.Event} ev
  */


  Canvas.prototype.onClick = function(ev) {
    var object, position;

    if (ev.target === this.rootElement_) {
      object = null;
    } else {
      object = this.getChild(this.getObjectIdByElement(ev.target));
    }
    position = goog.style.getRelativePosition(ev, ev.currentTarget);
    return this.dispatchEvent(new dm.ui.Canvas.Click(object, position));
  };

  /**
   * @param {goog.events.Event} ev
   * @param {goog.events.EventType=} endAction Action that stops moving
  */


  Canvas.prototype.onCaughtTable = function(ev, endAction) {
    var mouseMoveEvent,
      _this = this;

    if (endAction == null) {
      endAction = goog.events.EventType.MOUSEUP;
    }
    this.move = {
      object: ev.target,
      offset: ev.catchOffset
    };
    goog.dom.classes.add(this.move.object, 'move');
    mouseMoveEvent = goog.events.EventType.MOUSEMOVE;
    goog.events.listen(document, mouseMoveEvent, this.moveTable);
    return goog.events.listenOnce(document, endAction, function() {
      goog.dom.classes.remove(_this.move.object, 'move');
      _this.move = {
        object: null,
        offset: null
      };
      return goog.events.unlisten(document, mouseMoveEvent, _this.moveTable);
    });
  };

  /**
   * @param {HTMLElement} table
  */


  Canvas.prototype.clickedTable = function(table) {};

  Canvas.prototype.moveTable = function(ev) {
    var offsetInCanvas, tabSize, x, y;

    offsetInCanvas = goog.style.getRelativePosition(ev, this.rootElement_);
    x = offsetInCanvas.x - this.move.offset.x;
    y = offsetInCanvas.y - this.move.offset.y;
    tabSize = this.move.object.getSize ? this.move.object.getSize() : goog.style.getSize(this.move.object);
    if (x + tabSize.width > this.size_.width) {
      x = this.size_.width - tabSize.width;
    } else if (x < 0) {
      x = 0;
    }
    if (y + tabSize.height > this.size_.height) {
      y = this.size_.height - tabSize.height;
    } else if (y < 0) {
      y = 0;
    }
    if (this.move.object.setPosition) {
      this.move.object.setPosition(x, y);
    } else {
      goog.style.setPosition(this.move.object, x, y);
    }
    if (this.move.object instanceof dm.ui.Table) {
      return this.move.object.dispatchEvent(dm.ui.Table.EventType.MOVE);
    }
  };

  /**
  	* Save table element internaly and call function for render to DOM
   * @param {(dm.ui.Table)} table
  */


  Canvas.prototype.addTable = function(table) {
    this.addChild(table, false);
    return this.addTableInternal_(table);
  };

  /**
   * Add element to DOM
   * @param {(dm.ui.Table|Element)} table
  */


  Canvas.prototype.addTableInternal_ = function(table) {
    if (table.render != null) {
      return table.render(this.rootElement_);
    } else {
      return goog.dom.appendChild(this.rootElement_, table);
    }
  };

  /**
   * @param {(dm.ui.Relation)} relation
  */


  Canvas.prototype.addRelation = function(relation) {
    this.addChild(relation, false);
    return relation.draw(canvas);
  };

  /**
  	# @param {SVGPath} relation
  */


  Canvas.prototype.clickedRelation = function(relation) {};

  /**
   * @param {goog.math.Coordinate} startCoords
  */


  /*
  	setStartRelationPoint: (startCoords)->
  		@startRelationPath = new goog.graphics.Path()
  		@startRelationPath.moveTo startCoords.x, startCoords.y
  		
  		if @clueRelation
  			goog.style.showElement @clueRelation.getElement(), true
  			@clueRelation.setPath @startRelationPath
  		else
  			stroke = new goog.graphics.Stroke 1, '#000'
  			@clueRelation = @svg.drawPath @startRelationPath, stroke
  			goog.style.showElement @clueRelation.getElement(), true
  
  	moveEndRelationPoint:(ev) =>
  		point = goog.style.getRelativePosition ev, @html
  
  		newPath = @startRelationPath.clone()
  		newPath.lineTo point.x, point.y
  		
  		@clueRelation.setPath newPath
  
  	placeRelation: (endCoords, startTab, endTab) =>
  		goog.style.showElement @clueRelation.getElement(), false
  		@startRelationPath = undefined
  
  		id = dm.actualModel.addRelation @svg, startTab, endTab
  
  		startTabName = dm.actualModel.getTableById startTab
  		endTabName = dm.actualModel.getTableById endTab
  
  		dm.relationDialog.setValues startTabName, endTabName
  		dm.relationDialog.show id
  */


  /**
   * @param {Element} element
   * @return {string}
  */


  Canvas.prototype.getObjectIdByElement = function(element) {
    if (element === this.rootElement_) {
      return null;
    }
    while (!element.id) {
      element = goog.dom.getParentElement(element);
    }
    return element.id;
  };

  return Canvas;

})(goog.graphics.SvgGraphics);

goog.addSingletonGetter(dm.ui.Canvas);

dm.ui.Canvas.EditObject = (function(_super) {
  __extends(EditObject, _super);

  /**
   * @param {HTMLElement}
   * @constructor
   * @extends {goog.events.Event}
  */


  function EditObject(obj) {
    EditObject.__super__.constructor.call(this, dm.ui.Canvas.EventType.OBJECT_EDIT, obj);
  }

  return EditObject;

})(goog.events.Event);

dm.ui.Canvas.Click = (function(_super) {
  __extends(Click, _super);

  /**
   * @param {(dm.ui.Table|dm.ui.Relation)}
   * @param {goog.math.Coordinate} position Position in canvas where was clicked
   * @constructor
   * @extends {goog.events.Event}
  */


  function Click(obj, position) {
    this.position = position;
    Click.__super__.constructor.call(this, dm.ui.Canvas.EventType.CLICK, obj);
  }

  return Click;

})(goog.events.Event);

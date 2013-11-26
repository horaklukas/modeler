var relationStroke, strokeBg,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

goog.provide('dm.ui.Relation');

goog.require('dm.ui.Table.EventType');

goog.require('goog.graphics.SvgGroupElement');

goog.require('goog.graphics.SvgPathElement');

goog.require('goog.graphics.Path');

goog.require('goog.graphics.SolidFill');

goog.require('goog.graphics.Stroke');

goog.require('goog.ui.IdGenerator');

strokeBg = new goog.graphics.Stroke(10, 'transparent');

relationStroke = new goog.graphics.Stroke(2, '#000');

dm.ui.Relation = (function(_super) {
  __extends(Relation, _super);

  /**
   * @const
   * @static
  */


  Relation.width = 2;

  /**
  	* @param {dm.model.Relation}
   * @param {dm.ui.Table}
   * @param {dm.ui.Table}
   * @constructor
  */


  function Relation(relationModel, parentTab, childTab) {
    this.getRelationPoints = __bind(this.getRelationPoints, this);
    this.getRelationPath = __bind(this.getRelationPath, this);
    this.recountPosition = __bind(this.recountPosition, this);
    /**
      * @type {string}
    */

    /**
      * @type {dm.model.Relation}
    */
    this.setModel(relationModel);
    /**
      * @type {dm.ui.Table}
    */

    this.parentTab = parentTab;
    /**
      * @type {dm.ui.Table}
    */

    this.childTab = childTab;
    /**
      * @type {goog.graphics.SvgPathElement}
    */

    this.relationPath_ = null;
  }

  /**
   * @param {dm.ui.Canvas} canvas
  */


  /*
  	addTo: (canvas) ->
  		path = @getRelationPath(new goog.graphics.Path)
  		
  		@relationBg_ = canvas.drawPath path, strokeBg
  		@relationPath_ = canvas.drawPath path, relationStroke
  		
  		#@relationPath_.getElement().setAttribute 'id', @id_
  
  		if @model_ then @setRelationType()
  
  		goog.events.listen @parentTab, dm.ui.Table.EventType.MOVE, @recountPosition
  		goog.events.listen @childTab, dm.ui.Table.EventType.MOVE, @recountPosition
  */


  /**
   * @param {dm.ui.Canvas} canvas
  */


  Relation.prototype.draw = function(canvas) {
    var path;

    path = this.getRelationPath(new goog.graphics.Path);
    this.relationGroup_ = canvas.createGroup();
    this.relationBg_ = canvas.drawPath(path, strokeBg, null, this.relationGroup_);
    this.relationPath_ = canvas.drawPath(path, relationStroke, null, this.relationGroup_);
    this.relationGroup_.getElement().id = this.getId();
    if (this.model_) {
      this.setRelationType();
    }
    goog.events.listen(this.parentTab, dm.ui.Table.EventType.MOVE, this.recountPosition);
    return goog.events.listen(this.childTab, dm.ui.Table.EventType.MOVE, this.recountPosition);
  };

  /**
   * @param {dm.model.Relation} model
  */


  Relation.prototype.setModel = function(model) {
    this.model_ = model;
    return goog.events.listen(this.model_, 'type-change', this.setRelationType);
  };

  Relation.prototype.recountPosition = function() {
    this.relationPath_.setPath(this.getRelationPath(new goog.graphics.Path));
    return this.relationBg_.setPath(this.getRelationPath(new goog.graphics.Path));
  };

  /**
  	* @param {goog.graphics.Path} path Path object to set points on
   * @return {goog.graphics.Path} new relation path
  */


  Relation.prototype.getRelationPath = function(path) {
    var points;

    points = this.getRelationPoints();
    /*
    		widthHalf = dm.ui.Relation.width / 2
    
    		if points.start.edge in ['top', 'bottom'] 
    			path.moveTo points.start.coords.x - widthHalf, points.start.coords.y
    		else
    			path.moveTo points.start.coords.x, points.start.coords.y - widthHalf
    		
    		if points.stop.edge in ['top', 'bottom']
    			path.lineTo points.stop.coords.x - widthHalf, points.stop.coords.y
    			path.lineTo points.stop.coords.x + widthHalf, points.stop.coords.y
    		else
    			path.lineTo points.stop.coords.x, points.stop.coords.y - widthHalf
    			path.lineTo points.stop.coords.x, points.stop.coords.y + widthHalf
    
    		if points.start.edge in ['top', 'bottom']
    			path.lineTo points.start.coords.x + widthHalf, points.start.coords.y
    		else
    			path.lineTo points.start.coords.x, points.start.coords.y + widthHalf
    */

    path.moveTo(points.start.coords.x, points.start.coords.y);
    return path.lineTo(points.stop.coords.x, points.stop.coords.y);
  };

  /**
   * @return {Object.<string,goog.math.Coordinate>}
  */


  Relation.prototype.getRelationPoints = function() {
    var dist, dists, distsPoint, eCoord, ePos, eTab, result, sCoord, sPos, sTab;

    sTab = this.getTableConnectionPoints(this.parentTab);
    eTab = this.getTableConnectionPoints(this.childTab);
    dists = [];
    distsPoint = [];
    for (sPos in sTab) {
      sCoord = sTab[sPos];
      for (ePos in eTab) {
        eCoord = eTab[ePos];
        dist = this.getPathDistance(sPos, sCoord, ePos, eCoord);
        if (dist !== false) {
          dists.push(dist);
          distsPoint[dist] = [sPos, ePos];
        }
      }
    }
    if (dists.length === 0) {
      result = ['top', 'top'];
    } else {
      result = distsPoint[Math.min.apply(Math, dists)];
    }
    return {
      start: {
        edge: result[0],
        coords: sTab[result[0]]
      },
      stop: {
        edge: result[1],
        coords: eTab[result[1]]
      }
    };
  };

  /**
   *
   * @param {string} pos1 Name of first connection point (r = right, l = left, 
   *  t = top, b = bottom)
   * @param {goog.math.Coordinate} coord1
   * @param {string} pos2 Name of second connection point (r = right, l = left, 
   *  t = top, b = bottom)
   * @param {goog.math.Coordinate} coord2
   * @return {number|boolean} returns number of distance, if it's possible from
   * points position else return false
  */


  Relation.prototype.getPathDistance = function(pos1, coord1, pos2, coord2) {
    if (pos1 === pos2 || (((pos1 !== 'right' && pos2 !== 'left') || coord1.x < coord2.x) && ((pos1 !== 'left' && pos2 !== 'right') || coord1.x > coord2.x) && ((pos1 !== 'bottom' && pos2 !== 'top') || coord1.y < coord2.y) && ((pos1 !== 'top' && pos2 !== 'bottom') || coord1.y > coord2.y))) {
      return Math.abs(coord1.x - coord2.x) + Math.abs(coord1.y - coord2.y);
    } else {
      return false;
    }
  };

  /**
   * @param {dm.ui.Table} table
   * @relation {Object.<string, goog.math.Coordinate>}
  */


  Relation.prototype.getTableConnectionPoints = function(table) {
    var bounds, tableElement;

    tableElement = table.getElement();
    bounds = goog.style.getBounds(tableElement);
    bounds.top -= 31;
    bounds.left -= 2;
    return {
      'top': new goog.math.Coordinate(bounds.left + bounds.width / 2, bounds.top),
      'right': new goog.math.Coordinate(bounds.left + bounds.width, bounds.top + bounds.height / 2),
      'left': new goog.math.Coordinate(bounds.left, bounds.top + bounds.height / 2),
      'bottom': new goog.math.Coordinate(bounds.left + bounds.width / 2, bounds.top + bounds.height)
    };
  };

  /**
   *
   * @param {goog.math.Coordinate} start Relation start point coordinates
   * @param {string} sPos Position of start relation point
   * @param {goog.math.Coordinate} end Relation end point coordinates
   * @param {string} ePos Position of end relation point
   * @return {Array.<goog.math.Coordinate>} Two relation break points
  */


  /*
  	getBreakPoints: (start, sPos, end, ePos) ->
  		horiz = ['left','right']
  		vert = ['top', 'bottom']
  
  		# if connection points are in same direction, there are two break points
  		# otherwise there is only one break point
  		if sPos in horiz and ePos in horiz
  			x = ((end.x - start.x) / 2) + start.x
  
  			b1 = new goog.math.Coordinate x, start.y
  			b2 = new goog.math.Coordinate x, end.y
  		else if sPos in vert and ePos in vert
  			y = ((end.y - start.y) / 2) + start.y
  
  			b1 = new goog.math.Coordinate start.x, y
  			b2 = new goog.math.Coordinate end.x, y
  		else
  			if sPos is 'right' or sPos is 'left'
  				b1 = b2 = new goog.math.Coordinate end.x, start.y
  			if ePos is 'right' or ePos is 'left'
  				b1 = b2 = new goog.math.Coordinate start.x, end.y
  
  		console.log sPos, ePos, b1, b2
  
  		[b1, b2]
  */


  /**
  	* Changes relation stroke typ by identifying
  */


  Relation.prototype.setRelationType = function() {
    var identify, relationElement;

    identify = this.model_.isIdentifying();
    relationElement = this.relationPath_.getElement();
    if (identify) {
      return relationElement.removeAttribute('stroke-dasharray');
    } else {
      return relationElement.setAttribute('stroke-dasharray', '10 5');
    }
  };

  return Relation;

})(goog.ui.Component);

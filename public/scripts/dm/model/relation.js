var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

goog.provide('dm.model.Relation');

goog.require('goog.events.EventTarget');

dm.model.Relation = (function(_super) {
  __extends(Relation, _super);

  /**
   * @param {boolean} identify True if relation is identifying
   * @constructor
   * @extends {goog.events.EventTarget}
  */


  function Relation(identify) {
    Relation.__super__.constructor.call(this);
    this.identifying_ = identify;
  }

  /*
  	setRelatedTables: (parent, child) =>
  		@startTab = parent
  		@endTab = child
  */


  /**
  	* @param {boolean} identify True if relation is identyfing
  */


  Relation.prototype.setType = function(identify) {
    this.identifying_ = identify;
    return this.dispatchEvent('type-change');
  };

  /**
  	* @return {boolean}
  */


  Relation.prototype.isIdentifying = function() {
    return this.identifying_;
  };

  return Relation;

})(goog.events.EventTarget);

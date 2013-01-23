/**
* @module
*/
var Canvas;

Canvas = {
  /**
   * 
   * @param {jQueryObject} id Id of element to init canvas on
   * @param {Function} cb Callback to be invoked when init is finished
  */
  init: function(canvasObj, cb) {
    this.obj = canvasObj;
    this.witdh = canvasObj.width();
    this.height = canvasObj.height();
    this.self = Raphael(this.obj.attr('id'), this.witdh, this.height);
    if (cb) return cb();
  },
  on: function(event, target, cb) {
    return this.obj.on(event, target, cb);
  },
  off: function(event, target, cb) {
    return this.obj.off(event, target, cb);
  }
};

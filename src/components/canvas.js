var Canvas;

Canvas = (function() {

  function Canvas(id) {
    this.object = $("#" + id);
    this.object.addClass('canvas');
    this.w = this.object.witdh();
    this.h = this.object.height();
  }

  return Canvas;

})();

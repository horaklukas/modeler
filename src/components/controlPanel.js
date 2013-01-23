/**
* @module
*/
var ControlPanel;

ControlPanel = {
  obj: null,
  activeTool: null,
  clueTable: null,
  /**
   * @param {jQueryObject} obj Control panel element selected by jQuery
   * @param {Function} cb Callback to be invoked after init finished
  */
  init: function(obj, cb) {
    this.obj = obj;
    this.obj.on('click', '.tool', this.toolActivated);
    if (cb) return cb();
  },
  toolActivated: function(ev) {
    var $tool, toolName;
    $tool = $(this);
    toolName = $tool.attr('name');
    $tool.addClass('active');
    ControlPanel.activeTool = toolName;
    ev.stopImmediatePropagation();
    return ControlPanel["" + toolName + "Init"]();
  },
  toolFinished: function(ev) {
    ControlPanel["" + ControlPanel.activeTool + "Finish"]();
    $('.active', this.obj).removeClass('active');
    return this.activeTool = null;
  },
  createTableInit: function() {
    if (!(this.clueTable != null)) {
      this.clueTable = Canvas.self.rect(0, 0, 100, 80, 2);
      this.clueTable.attr({
        fill: '#CCC',
        opacity: 0.5
      }).hide();
    }
    Canvas.on('mousemove', function(ev) {
      return ControlPanel.clueTable.show().attr({
        'x': ev.offsetX,
        'y': ev.offsetY
      });
    });
    Canvas.on('click', function(ev) {
      ControlPanel.clueTable.hide();
      new Table(Canvas.self, ev.offsetX, ev.offsetY, 100, 60);
      return ControlPanel.toolFinished();
    });
    return $(document).on('click', this.toolFinished);
  },
  createTableFinish: function() {
    Canvas.off('mousemove', this.moveClueTable);
    Canvas.off('click', this.create);
    return $(document).off('click', this.toolFinished);
  },
  createRelationshipInit: function() {},
  createRelationshipFinish: function() {}
};

if (!(typeof window !== "undefined" && window !== null)) {
  module.exports = ControlPanel;
}

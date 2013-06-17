/**
* @module
*/
var ControlPanel,
  _this = this;

ControlPanel = {
  obj: null,
  activeTool: null,
  clueTable: null,
  clueRelation: null,
  relStart: {
    x: null,
    y: null,
    id: null
    /**
     * @param {jQueryObject} obj Control panel element selected by jQuery
     * @param {Function} cb Callback to be invoked after init finished
    */
  },
  init: function(obj, cb) {
    this.obj = obj;
    this.obj.on('click', '.tool', this.toolActivated);
    if (cb) return cb();
  },
  toolActivated: function(ev) {
    var $activeTool, $tool, toolName;
    $tool = $(ev.target);
    $activeTool = $('.active', _this.obj);
    if ($activeTool.length) ControlPanel.toolFinished();
    if ($tool.is($activeTool)) return false;
    toolName = $tool.addClass('active').attr('name');
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
    if (this.clueTable == null) {
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
      App.actualModel.addTable(Canvas.obj, ev.offsetX, ev.offsetY);
      return ControlPanel.toolFinished();
    });
    return $(document).on('click', this.toolFinished);
  },
  createTableFinish: function() {
    ControlPanel.clueTable.hide();
    Canvas.off('mousemove');
    Canvas.off('click');
    return $(document).off('click', this.toolFinished);
  },
  createRelationInit: function(ev) {
    var canvasPos;
    Canvas.css({
      'cursor': 'crosshair'
    });
    canvasPos = Canvas.obj.position();
    return Canvas.on('click', '.table', function(ev) {
      var pos, startPath;
      if (!((ControlPanel.relStart.x != null) && (ControlPanel.relStart.y != null))) {
        pos = ControlPanel.relStart = {
          'x': ev.clientX - canvasPos.left,
          'y': ev.clientY - canvasPos.top
        };
        startPath = "M" + pos.x + " " + pos.y;
        ControlPanel.relStart.id = this.id;
        if (ControlPanel.clueRelation == null) {
          ControlPanel.clueRelation = Canvas.self.path(startPath);
        } else {
          ControlPanel.clueRelation.attr('path', startPath).show();
        }
        return Canvas.on('mousemove', function(ev) {
          return ControlPanel.clueRelation.attr('path', "" + startPath + "L" + (ev.clientX - canvasPos.left) + " " + (ev.clientY - canvasPos.top));
        });
      } else {
        App.actualModel.addRelation(Canvas.self, ControlPanel.relStart.id, this.id);
        return ControlPanel.toolFinished();
      }
    });
  },
  createRelationFinish: function() {
    var _ref;
    if ((_ref = ControlPanel.clueRelation) != null) _ref.hide();
    Canvas.css({
      'cursor': 'default'
    });
    Canvas.off('mousemove');
    Canvas.off('click', '.table');
    return this.relStart = {
      x: null,
      y: null
    };
  }
};

if (!(typeof window !== "undefined" && window !== null)) {
  module.exports = ControlPanel;
}
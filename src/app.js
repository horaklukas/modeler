var endTable, h, modelerCanvas, moveTable, newEntity, startTable, templateTable, w, x, y;

w = $('modelerCanvas').width();

h = $('modelerCanvas').height();

modelerCanvas = Raphael("modelerCanvas", w, h);

x = 0;

y = 0;

newEntity = false;

templateTable = modelerCanvas.rect.apply(modelerCanvas, [0, 0, 100, 60, 2]);

templateTable.attr({
  fill: '#CCC',
  opacity: 0.5
});

templateTable.hide();

moveTable = function(dx, dy) {
  return this.attr({
    x: x + dx,
    y: y + dy
  });
};

startTable = function() {
  x = this.attr('x');
  y = this.attr('y');
  return this.attr('opacity', 0.5);
};

endTable = function() {
  return this.attr('opacity', 1);
};

$('#modelerCanvas').on({
  'click': function(e) {
    var table, tableAttrs;
    if (newEntity === true) {
      tableAttrs = [e.offsetX, e.offsetY, 100, 60, 2];
      table = modelerCanvas.rect.apply(modelerCanvas, tableAttrs);
      table.attr({
        fill: '#EEE',
        stroke: '#000',
        opacity: 1
      });
      table.drag(moveTable, startTable, endTable);
      templateTable.hide();
      return $('#controlPanel [name=newTable]').trigger('tableCreated');
    }
  },
  'mousemove': function(e) {
    if (newEntity === true) {
      templateTable.show();
      return templateTable.attr({
        x: e.offsetX,
        y: e.offsetY
      });
    }
  }
}, 'svg');

$('#controlPanel').on({
  'click': function() {
    newEntity = true;
    return $(this).addClass('active');
  },
  'tableCreated': function() {
    newEntity = false;
    return $(thi).removeClass('active');
  }
}, '[name=newTable]');

$(document).on({
  'mouseup': function(ev) {
    return newEntity = false;
  }
});

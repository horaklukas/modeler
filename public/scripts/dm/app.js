var appElement, canvas, canvasElement, mainToolbar, relationDialog, tableDialog;

goog.provide('dm');

goog.require('dm.model.Table');

goog.require('dm.model.Relation');

goog.require('dm.ui.Table');

goog.require('dm.ui.Relation');

goog.require('dm.dialogs.TableDialog');

goog.require('dm.dialogs.RelationDialog');

goog.require('dm.model.Model');

goog.require('dm.ui.Canvas');

goog.require('dm.ui.Toolbar');

goog.require('goog.dom');

goog.require('goog.dom.classes');

goog.require('goog.events');

appElement = goog.dom.getElement('app');

canvasElement = goog.dom.getElement('modelerCanvas');

tableDialog = new dm.dialogs.TableDialog();

relationDialog = new dm.dialogs.RelationDialog();

dm.actualModel = new dm.model.Model('Model1');

canvas = new dm.ui.Canvas.getInstance();

canvas.render(canvasElement);

mainToolbar = new dm.ui.Toolbar();

mainToolbar.renderBefore(canvasElement);

goog.events.listen(canvas, dm.ui.Canvas.EventType.OBJECT_EDIT, function(ev) {
  var object;

  object = ev.target;
  if (object instanceof dm.ui.Relation) {
    return relationDialog.show(true, object);
  } else if (object instanceof dm.ui.Table) {
    return tableDialog.show(true, object);
  }
});

goog.events.listen(mainToolbar, dm.ui.Toolbar.EventType.CREATE, function(ev) {
  var rel, tab;

  switch (ev.objType) {
    case 'table':
      tab = new dm.ui.Table(new dm.model.Table(), ev.data.x, ev.data.y);
      canvas.addTable(tab);
      return tableDialog.show(true, tab);
    case 'relation':
      rel = new dm.ui.Relation(new dm.model.Relation(false), ev.data.parent, ev.data.child);
      return canvas.addRelation(rel);
  }
});

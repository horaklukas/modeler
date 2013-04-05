var App;

App = {};

App.actualModel = new Model('Model1');

Canvas.init($('#modelerCanvas'));

ControlPanel.init($('#controlPanel'));

App.actualModel.addTable(Canvas.obj, 100, 75);

App.actualModel.addTable(Canvas.obj, 500, 280);

App.actualModel.addTable(Canvas.obj, 100, 280);

App.actualModel.addRelation(Canvas.self, 'tab_0', 'tab_1');

App.actualModel.addRelation(Canvas.self, 'tab_0', 'tab_2');

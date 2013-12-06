var Server, app, expose, express, nib, port, routes, stylus, stylusCompile;

express = require('express');

expose = require('express-expose');

stylus = require('stylus');

nib = require('nib');

routes = require('./src/routes');

global.Server = Server = {};

Server.app = app = express();

Server.databases = {};

Server.databases.dbs = {};

Server.databases.list = [];

Server.databases.selected = null;

stylusCompile = function(str, path) {
  return stylus(str).set('filename', path).set('compress', true).use(nib())["import"]('nib');
};

app.configure(function() {
  app.set('view engine', 'jade');
  app.set('views', __dirname + '/views');
  app.use(express.json());
  app.use(express.urlencoded());
  app.use(express.methodOverride());
  app.use(stylus.middleware({
    src: __dirname + '/public',
    compile: stylusCompile
  }));
  app.use(express["static"](__dirname + '/public'));
  app.use(app.router);
  return app.use(express.errorHandler());
});

app.get('/', routes.intro);

app.post('/modeler', routes.app);

app.get('/modeler', routes.app);

port = process.env.PORT || 5000;

app.listen(port, function() {
  return console.log('Listening on port ' + port);
});

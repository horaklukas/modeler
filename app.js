// Generated by IcedCoffeeScript 1.4.0c
var Server, app, express, port, routes, stylus;

express = require('express.io');

stylus = require('stylus');

routes = require('./src/routes');

global.Server = Server = {};

Server.app = app = express();

Server.databases = {};

Server.databases.list = [];

app.http().io();

app.configure(function() {
  app.set('view engine', 'jade');
  app.set('views', __dirname + '/views');
  app.use(stylus.middleware({
    src: __dirname + '/public'
  }));
  app.use(express["static"](__dirname + '/public'));
  return app.use(app.router);
});

app.get('/', routes.intro);

app.get('/modeler', routes.app);

port = proces.env.port || 5000;

app.listen(port, function() {
  return console.log('Listening on port ' + port);
});

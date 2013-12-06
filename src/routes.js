var fs, helping, routes;

fs = require('fs');

helping = {
  loadDbDefinition: function(name, cb) {
    return fs.readFile("defs/" + name + ".json", 'utf8', function(err, cont) {
      if (err != null) {
        console.error(err);
        return;
      }
      return cb(JSON.parse(cont));
    });
  },
  renderWorkspace: function(res) {
    var options;

    options = {
      title: Server.databases.dbs[Server.databases.selected].name
    };
    res.expose({
      types: Server.databases.dbs[Server.databases.selected].types
    }, 'DB');
    return res.render('main', options);
  }
};

routes = {
  intro: function(req, res) {
    if (!Server.databases.list.length) {
      return fs.readdir('defs', function(err, files) {
        if (err) {
          return console.log('Error at reading defs dir!');
        } else {
          Server.databases.list = files.map(function(file) {
            return file.replace('.json', '');
          });
          return res.render('intro', {
            dbs: Server.databases.list
          });
        }
      });
    } else {
      return res.render('intro', {
        dbs: Server.databases.list
      });
    }
  },
  app: function(req, res) {
    if (!Server.databases.selected) {
      if (req.method === 'POST') {
        if (!req.body.dbs) {
          res.redirect('/');
          return;
        } else {
          Server.databases.selected = req.body.dbs;
          if (!Server.databases.dbs[req.body.dbs]) {
            helping.loadDbDefinition(req.body.dbs, function(def) {
              Server.databases.dbs[req.body.dbs] = {
                name: def.name,
                types: def.data.types
              };
              return helping.renderWorkspace(res);
            });
            return;
          }
        }
      }
      if (req.method === 'GET') {
        res.redirect('/');
        return;
      }
    }
    return helping.renderWorkspace(res);
  }
};

module.exports = routes;

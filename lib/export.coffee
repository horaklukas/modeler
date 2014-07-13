fs = require 'fs'
{spawn} = require 'child_process'
fspath = require 'path'
crypto = require 'crypto'
jade = require 'jade'
CleanCss = require 'clean-css'
#uglifyjs = require 'uglify-js'
dbs = require './dbs'

bowerComponentsPath = fspath.join __dirname, '../bower_components'
closurePath = fspath.join bowerComponentsPath, 'closure-library'
builderPath = fspath.join closurePath, 'closure/bin/build/closurebuilder.py'
publicDirPath = fspath.join __dirname, '..', 'public'
appSrcPath = fspath.join publicDirPath, 'scripts/dm/'

module.exports = exportApp =
  reactJsPath: fspath.join bowerComponentsPath, 'react/react.min.js'

  ###*
  * @param {function(string)} cb
  ###
  getAppScript: (cb) ->
    appScript = ''
    error = ''
    args = [
      "--root=#{closurePath}"
      "--root=#{appSrcPath}"
      "--root=#{fspath.join(publicDirPath, 'scripts/dme')}"
      "--input=#{fspath.join(publicDirPath, 'scripts/dme', 'app-exported.js')}"
      '--output_mode=script'
    ]

    # ensure that builder script can been executed
    fs.chmod builderPath, '0777', (err) ->
      if err then return cb "Error at changind permissions: #{err}"
      
      builder = spawn builderPath, args

      builder.stdout.on 'data', (data) ->
        appScript += data

      builder.stderr.on 'data', (data) ->
        error += data

      builder.on 'close', (code) ->
        if code isnt 0 then cb(error) else cb null, appScript

      builder.on 'error', (err) ->
        cb err

  ###*
  * @param {string} dbId
  * @param {Object} model
  * @param {function(string)} cb
  ###
  getDbDefScript: (dbId, model, cb) ->
    definition = dbs.getDb dbId

    if definition? then cb null, exportApp.createDef definition, dbId, model
    else dbs.loadAllDefinitions ->
      cb null, exportApp.createDef(dbs.getDb(dbId), dbId, model)

  createDef: (def, defId, model) ->
    appId = crypto.createHash('md5').update((new Date).getTime().toString())
      .digest 'hex'

    """
    var dmDefault = {
      'db': #{JSON.stringify def},
      'dbId': '#{defId}',
      'model': #{JSON.stringify model},
      'id': '#{appId}'
    };
    """

  ###*
  * @param {function(string)} cb
  ###
  getReactJsScript: (cb) ->
    fs.readFile exportApp.reactJsPath, 'utf8', cb

  getAppStyles: (cb) ->
    ###
    styleFiles = [
      fspath.join publicDirPath, 'styles/dm.css'
      fspath.join closurePath, 'closure/goog/css/common.css'
      fspath.join closurePath, 'closure/goog/css/dialog.css'
      fspath.join closurePath, 'closure/goog/css/toolbar.css'
      fspath.join closurePath, 'closure/goog/css/button.css'
    ]
    async.map styleFiles, fs.readFile, cb
    ###
    
    styleFile = fspath.join publicDirPath, 'styles/dm-closure-included.css'
    fs.readFile styleFile, {encoding: 'utf8'}, (err, content) ->
      if err then cb(err) else cb null, content

  compileCss: (uncompiledCss) ->
    new CleanCss().minify uncompiledCss

  compileJs: (uncompiledJs) ->
    uglifyjs.minify uncompiledJs, {fromString: true}

  renderTemplate: (compiledJs, compiledCss, appVersion, cb) ->
    exportTemplatePath = fspath.join __dirname, '../views/app-exported.jade'
    options =
      pretty: true
      javascript: compiledJs
      appStyles: compiledCss
      version: appVersion

    jade.renderFile exportTemplatePath, options, (err, html) ->
      if err then cb "Error at rendering template: #{err}"
      else cb null, html
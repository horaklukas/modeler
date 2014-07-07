fs = require 'fs'
async = require 'async'
databases = require '../dbs'
appVersion = require('../../package').version
exportApp = require '../export'

###*
* POST request by ajax from select database dialog
###
exports.getList = (req, res) -> 
  databases.getList (err, list) ->
    if err? then res.send 500, err
    else res.json dbs: list

###*
* GET or POST request
###
exports.app = (req, res, next) ->
  switch req.method
    # ajax request, setting of selected db
    when 'POST'
      dbId = req.body.db
      # selected dbs id not exist for not known reason
      unless dbId then return res.send 400, 'Id of db doesnt exist'
      
      databases.setSelected dbId
      res.json databases.getDb(dbId)

    # browser request, usually page refresh
    when 'GET'
      exposeData = {}
      ###
      selectedId = databases.getSelected()
      if selectedId then selectedDb = databases.getDb selectedId
  
      if selectedDb
        exposeData.name = selectedDb.name
        exposeData.version = selectedDb.version
        exposeData.types = selectedDb.types
      ###
      databases.loadAllDefinitions (err, defs) ->
        if err then return next "Error at loading definitions #{err}"

        exposeData.dbs = defs

        page = 'main'
        page += '-devel' if @process.env.MODE is 'development'

        res.expose exposeData, 'dmAssets'
        res.render page, {title: 'Database not selected', version: appVersion}

###*
* POST request, invoke "save file" dialog for save model to JSON file
###
exports.saveModel = (req, res) ->
  res.attachment "#{req.body.name ? 'unknown'}.json"

  res.setHeader 'Content-Type', 'application/json'
  res.end req.body.model, 'utf8'

###*
* POST request that responses with content of selected file
###
exports.loadModel = (req, res) ->
  fs.readFile req.files.modelfile.path, (err, content) ->
    if err? then return res.send 500, err.code
    
    try res.json JSON.parse content
    catch e then res.send 500, 'Selected file isnt valid JSON'

exports.exportModel = (req, res) ->
  model = JSON.parse req.body.model
  dbId = req.body.dbid

  async.parallel {
    appsrc: exportApp.getAppScript
    dbdef: async.apply exportApp.getDbDefScript, dbId, model
    reactjs: exportApp.getReactJsScript
    styles: exportApp.getAppStyles
  }, (err, results) ->
    if err then return res.send 500, "Error at getting source code: #{err}"
    
    {reactjs, dbdef, appsrc} = results
    #js = exportApp.compileJs reactjs + '\n' + dbdef + '\n' + appsrc
    js = reactjs + '\n' + dbdef + '\n' + appsrc
    css = exportApp.compileCss results.styles

    exportApp.renderTemplate js, css, appVersion, (err, html) ->
      if err then return res.send 500, "Error at rendering template: #{err}"
      
      res.attachment "#{model.name.toLowerCase() ? 'exported'}.html"
      res.setHeader 'Content-Type', 'text/html'
      res.end html, 'utf8'

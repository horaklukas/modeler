goog.provide 'dm.core.handlers'

goog.require 'dm.core'
goog.require 'dm.core.state'
goog.require 'dm.model.Table'
goog.require 'dm.model.Relation'
goog.require 'dm.ui.Table'
goog.require 'dm.ui.Relation'
goog.require 'dm.ui.InfoDialog'
goog.require 'dm.sqlgen.list'
goog.require 'goog.object'

dm.core.handlers =
  ###*
  * @param {string} action Id of action selected at intro dialog
  ###
  introActionSelected: (action) ->
    introShowCb = dm.core.getDialog('intro').show

    switch action
      when 'new'
        dm.core.getDialog('selectDb').show dm.core.handlers.createNewModel
      when 'load'
        dm.core.getDialog('loadModel').show introShowCb
      when 'byversion'
        dm.core.getDialog('version').show(
          null, dm.core.handlers.onVersionSelect, introShowCb
        )
      when 'fromdb' then dm.core.getDialog('reeng').show introShowCb
      else return

    dm.core.getDialog('intro').hide()
  
  ###*
  * @param {Object} json JSON representation of model
  ###
  modelLoad: (json) ->
    dm.core.getModelManager().createActualFromLoaded(
      json.name, json.tables, json.relations
    )
    
    # set model's db as a actual
    dm.core.state.setActualRdbs json.db
    dm.core.state.setSaved true    

  createNewModel: (db) ->
    dm.core.state.setActualRdbs db
    dm.core.getDialog('input').show(
      'NewModel', 'Type name of new model'
      dm.core.getModelManager().bakupOldCreateNewActual
    )
    dm.core.state.clearVersioned()
    dm.core.state.setSaved true

  saveModelRequest: (ev) ->
    actualModel = dm.core.getActualModel()
    model = actualModel.toJSON()
    model['db'] = dm.core.state.getActualRdbs()

    data =
      'name': actualModel.name.toLowerCase()
      'model': JSON.stringify model

    dm.core.state.setActual 'saving'
    dm.core.submitWithHiddenForm '/save/model', data

  saveSqlRequest: (filename, sql) ->
    data =
      'name': filename
      'sql': sql

    dm.core.submitWithHiddenForm '/save/sql', data

  exportModelRequest: (ev) ->
    data =
      'dbid': dm.core.state.getActualRdbs()
      'model': JSON.stringify dm.core.getActualModel().toJSON()

    dm.core.state.setActual 'exporting'
    dm.core.submitWithHiddenForm '/export', data

  generateSqlRequest: (ev) ->
    actualDbType = dm.core.state.getActualRdbs().match(/^([a-zA-Z]*)\-/)?[1]
    generator = dm.sqlgen.list[actualDbType ? 'sql']
    actualModel = dm.core.getActualModel()


    sql = generator.generate(
      tables: actualModel.getTables()
      relations: actualModel.getRelations()
    )

    dm.core.getDialog('sqlCode').show sql

  ###*
  * @param {Object.<string, object>} data Object containing keys `tables` and 
  *  `relations`
  ###
  reengRequest: (data) ->
    dm.core.getDialog('input').show(
      'Reengineered model', 'Type name of reenginered model', (name) -> 
        dm.core.getModelManager().createActualFromCatalogData(
          name, data['columns'], data['relations']
        )

        # set model's db as a actual with replaced dots at version string
        dm.core.state.setActualRdbs data['db'].replace '.', '-'
        dm.core.state.clearVersioned()
        dm.core.state.setSaved true
    )

  versionModelRequest: ->
    actualModel = dm.core.getActualModel()
    model = actualModel.toJSON()
    model['db'] = dm.core.state.getActualRdbs()

    props = model: 'model': model 
    
    if (repo = dm.core.state.getVersioned())? then props.repo = repo

    dm.core.getDialog('version').show(
      props, (repo) ->
        dm.core.getDialog('info').show 'Model successfuly versioned'
        dm.core.state.setVersioned repo 
        dm.core.state.setSaved true
    )

  statusChange: (ev) ->
    dm.core.getDialog('input').show(
      dm.core.getActualModel().name
      'Type and confirm model name'
      dm.core.getModelManager().changeActualModelName
    )

  editObject: ({target}) ->
    actualModel = dm.core.getActualModel()
    model = target.getModel()

    if target instanceof dm.ui.Relation
      {parent, child} = model.tables
      tables = 
        parent: 
          id: parent, name: actualModel.getTableById(parent).getName()
        child: 
          id: child, name: actualModel.getTableById(child).getName()

      dm.core.getDialog('relation').show model, tables
    else if target instanceof dm.ui.Table
      dm.core.getDialog('table').show model

  moveObject: (e) ->
    canvas = dm.core.getCanvas()
    actualModel = dm.core.getActualModel()
    relationsIds = actualModel.getRelationsByTable(e.target.getId()) ? []

    for relId in relationsIds
      relation = actualModel.getRelationUiById relId 
      {parent, child} = relation.getModel().tables

      relation.recountPosition(
        canvas.getChild(parent).getElement()
        canvas.getChild(child).getElement()
      )
  deleteObject: ({target}) =>
    model = target.getModel()
    modelManager = dm.core.getModelManager()
    actualModel = dm.core.getActualModel()

    if confirm("You want to delete \"#{model.getName()}\". Are you sure?") is true
      
      if target instanceof dm.ui.Relation
        modelManager.deleteRelation target
      else if target instanceof dm.ui.Table
        relatedRelations = actualModel.getRelationsByTable target.getId()

        for relId in (relatedRelations ? [])
          modelManager.deleteRelation actualModel.getRelationUiById relId

        modelManager.deleteTable target

  createObject: (ev) ->    
    switch ev.objType
      when 'table'
        dm.core.getDialog('input').show(      
          'NewTable', 'Type name of new table'
          goog.partial dm.core.handlers.tableNameInput, ev
        )
      when 'relation'
        modelManager = dm.core.getModelManager()
        actualModel = dm.core.getActualModel()
        {parent, child, identifying} = ev.data
        #rel.setRelatedTables parent.getModel(), child.getModel() 

        model = new dm.model.Relation identifying, parent, child
        tables = 
          parent: 
            'id': parent, 'name': actualModel.getTableById(parent).getName()
          child: 
            'id': child, 'name': actualModel.getTableById(child).getName()

        modelManager.addRelation model
        dm.core.getDialog('relation').show model, tables

  ###*
  * Handler for input dialog when user type name of new table and confirm
  *
  * @param {goog.events.Event} ev Event object from original `createObject` 
  *  handler
  * @param {string} name Table name
  ###
  tableNameInput: (ev, name) ->
    modelManager = dm.core.getModelManager()
    actualModel = dm.core.getActualModel()
    # used to fix table name duplicity
    originalName = name
    counter = 0

    while actualModel.getTableIdByName(name)?
      name = originalName + (counter++).toString()

    if name isnt originalName then dm.core.getDialog('info').show(
      "Table name was changed from \"#{originalName}\" to \"#{name}\" " + 
      "for ensuring uniqueness"
    )

    model = new dm.model.Table name, []
    modelManager.addTable model, ev.data.x, ev.data.y
    dm.core.getDialog('table').show model

  tableNameChange: (ev) ->
    model = ev.target
    originalName = name = model.getName()

    actualModel = dm.core.getActualModel()
    counter = 0

    tables = actualModel.getTablesByName()
    
    if goog.isArray tables[name]
      while tables[name]? then name = originalName + (counter++).toString()

    if name isnt originalName
      model.setName name
      dm.core.getDialog('info').show(
        "Table name was changed from \"#{originalName}\" to \"#{name}\" " + 
        "for ensuring uniqueness!"
      )

  onVersionSelect: (model, repo) ->
    dm.core.state.setVersioned repo
    dm.core.handlers.modelLoad model

  onServerReconnect: ->
    dm.core.enableServerRelatedTools true

  onServerDisconnect: (enable) ->
    console.log 'Server disconnected at socket.io channel'
    dm.core.enableServerRelatedTools false

  windowUnload: (ev) ->
    state = dm.core.state.getActual()
    
    # when saving model dont show dialog
    if state is 'saving' or state is 'exporting'
      dm.core.state.setActual ''
      return 

    unless dm.core.state.isSaved()
      return "Model \"#{dm.core.getActualModel().name}\" isnt saved, really exit?"

    ###
    msg = 'Really unload?'
    {IE, FIREFOX} = goog.userAgent.product

    if IE or FIREFOX then ev.getBrowserEvent().returnValue = msg
    else msg
    ###

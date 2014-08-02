goog.provide 'dm.core'

goog.require 'goog.dom'

dm.core =
  toolbar: null
  canvas: null
  modelManager: null
  dialogs: {}
  dbDefs: {}

  init: (canvas, toolbar, manager, defs) ->
    dm.core.toolbar = toolbar
    dm.core.canvas = canvas
    dm.core.modelManager = manager
    dm.core.dbDefs = defs

  ###*
  * @param {string} action Url for submit
  * @param {Object.<string,string>} data Form data that will be submitted 
  ###
  submitWithHiddenForm: (action, data) ->
    data = for name, value of data
      goog.dom.createDom 'input', {'type':'hidden', 'name':name, 'value':value }

    form = goog.dom.createDom 'form', {'action':action, 'method':'POST'}, data
    goog.dom.appendChild goog.dom.getElement('app'), form

    form.submit()
    goog.dom.removeNode form

  ###*
  * @param {boolean=} enable
  ###
  enableServerRelatedTools: (enable = true) ->
    toolbar = dm.core.getToolbar()

    toolbar.getChild('save-tool').setEnabled enable
    toolbar.getChild('load-tool').setEnabled enable
    toolbar.getChild('exp-tool').setEnabled enable
    toolbar.getChild('vers-tool').setEnabled enable

  getToolbar: ->
    dm.core.toolbar

  getCanvas: ->
    dm.core.canvas

  getActualModel: ->
    dm.core.modelManager.actualModel

  getModelManager: ->
    dm.core.modelManager

  registerDialog: (name, dialog) ->
    dm.core.dialogs[name] = dialog

  getDialog: (name) ->
    dm.core.dialogs[name]

  getDbDef: (id) ->
    dm.core.dbDefs[id]
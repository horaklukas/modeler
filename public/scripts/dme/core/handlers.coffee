goog.provide 'dme.core.handlers'

goog.require 'dm.core'
goog.require 'dme.core'
goog.require 'dm.core.state'
goog.require 'dm.ui.InfoDialog'

dme.core.handlers =
  ###*
  * @param {goog.events.Event} ev
  ###
  saveRequest: (ev) ->
    storage = dme.core.getStorage()

    if storage?
      storage.set dme.core.getId(), dm.core.getActualModel().toJSON()
      dm.core.state.setSaved true
      text = 'Save successful'
    else
      text = 'Storage mechanism isnt available!'  

    dm.core.getDialog('info').show text

  ###*
  * @param {goog.events.Event} ev
  ###
  loadRequest: (ev) ->
    infoType = dm.ui.InfoDialog.types.INFO
    storage = dme.core.getStorage()

    if storage?
      json = storage.get dme.core.getId()

      if json
        dm.core.getModelManager().createActualFromLoaded(
          json.name, json.tables, json.relations
        )
        dm.core.state.setSaved true
        text = 'Load was successful'
      else
        text = 'Model can\'t been loaded since it wasn\'t saved yet'
        infoType = dm.ui.InfoDialog.types.WARN 
    else  
      text = 'Storage mechanism isnt available!'
    
    dm.core.getDialog('info').show text, infoType
goog.provide 'dm.core.state'

goog.require 'dm.core'
goog.require 'goog.dom'

dm.core.state =
  ###*
  * @type {(string|null)}
  ###
  actualRdbs: null

  ###*
  * If last version of actual model is saved
  * @type {boolean}
  ###
  saved: true

  ###*
  * @type {string}
  ###
  actual: ''

  ###*
  * @type {(string|null)}
  ###
  repo: null

  setActual: (type) ->
    dm.core.state.actual = type

  getActual: ->
    dm.core.state.actual

  ###*
  * @param {boolean} saved
  ###
  setSaved: (saved) ->
    dm.core.state.saved = saved
    dm.core.getToolbar().setStatus null, null, saved

  ###*
  * @return {boolean}
  ###
  isSaved: ->
    dm.core.state.saved

  ###*
  * @param {string} db Id of db to set as actualRdbs
  ###
  setActualRdbs: (db) ->
    dbDef = dm.core.getDbDef db

    console.error 'Selected database isnt defined' if not dbDef

    dm.core.state.actualRdbs = db
    dm.core.getDialog('table').setProps types: dbDef.types

    goog.dom.setTextContent(
      goog.dom.getElementsByTagNameAndClass('title')[0], dbDef.name
    )
    dm.core.getToolbar().setStatus null, "#{dbDef.name} #{dbDef.version}"

  getActualRdbs: ->
    dm.core.state.actualRdbs

  clearVersioned: ->
    dm.core.state.setVersioned null

  ###*
  * @param {string} repo Name of repository
  ###
  setVersioned: (repo) ->
    dm.core.state.repo = repo

  ###*
  * @return {(string|null)}
  ###
  getVersioned: ->
    dm.core.state.repo ? null
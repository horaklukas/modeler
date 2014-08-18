goog.provide 'dme.core'

goog.require 'goog.storage.Storage'
goog.require 'goog.storage.mechanism.HTML5LocalStorage'

dme.core =
	appId: null
	storage: null

	###*
  * @param {string} appId App id for use as a key at local storage
	###
	init: (appId) ->
		dme.core.appId = appId

		# storage mechanism for saving/loading edited model
		mechanism = new goog.storage.mechanism.HTML5LocalStorage

		if mechanism.isAvailable()
			dme.core.storage = new goog.storage.Storage mechanism

	###*
  * @return {string}
	###
	getId: ->
		dme.core.appId

	getStorage: ->
		dme.core.storage
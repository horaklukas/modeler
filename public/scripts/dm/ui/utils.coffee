goog.provide 'dm.ui.utils'

goog.require 'goog.string'

dm.ui.utils.createElementFromReactComponent = (reactComponent) ->
  componentHtml = React.renderComponentToStaticMarkup reactComponent
  wrapper = goog.dom.createElement 'div'

  wrapper.innerHTML = componentHtml

  goog.dom.getFirstElementChild wrapper

  ###*
  * @param {(number|string)} ms Miliseconds since...you know, the magic date
  * at unix systems
  * @return {string} date time
  ###
dm.ui.utils.convertMsToDateTimeFormat = (ms) ->
  ms = goog.string.toNumber(ms) if goog.isString ms
  d = new Date ms
  month = goog.string.padNumber d.getMonth() + 1, 2
  hour = goog.string.padNumber d.getHours(), 2
  min = goog.string.padNumber d.getMinutes(), 2
  sec = goog.string.padNumber d.getSeconds(), 2

  "#{d.getFullYear()}/#{month}/#{d.getDate()} #{hour}:#{min}:#{sec}" 

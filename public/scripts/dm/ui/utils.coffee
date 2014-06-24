goog.provide 'dm.ui.tmpls.createElementFromReactComponent'

dm.ui.tmpls.createElementFromReactComponent = (reactComponent) ->
	componentHtml = React.renderComponentToStaticMarkup reactComponent
	wrapper = goog.dom.createElement 'div'

	wrapper.innerHTML = componentHtml

	goog.dom.getFirstElementChild wrapper
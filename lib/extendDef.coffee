###*
* Function for extending definition with another one, e.g.
* definition of sql-92 with definition of postgresql
* We can't use `extend` module from npm registry because there is one 
* important feature that we need for extending - concating of arrays and not 
* rewriting values on same indexes
*
* @param {Object} def1
* @param {Object} def2
###
module.exports = extend = (def1, def2) ->
	for name, value of def2
		if Array.isArray value
			tmpArr = if def1[name] then def1[name].concat value else value 
			# filter duplicated vaues
			def1[name] = tmpArr.filter (elem, pos, arr) -> arr.indexOf(elem) is pos
		else if value.constructor is Object
			extend def1[name], value
		else
			def1[name] = value
class Anchor
	###*
  * @param canvas
  * @param {String} type One of `t`,`l`,`r`,`b` position types
  * of anchor
  * @param {Object} tabLT X and y coordinate of table left top corner 
  * @param {Object} tabRB X and y coordinate of table right bottom corner
	###
	constructor: (canvas, type, tabLT, tabRB) ->
		x = tabLT.x - 20
		y = tabLT.y - 20

		if type in ['t','b'] then x += (tabRB.x - tabLT.x) / 2
		else if type is 'r' then x += (tabRB.x - tabLT.x) + 20

		if type in ['l','r'] then y += (tabRB.y - tabLT.y) / 2
		else if type is 'b' then y += (tabRB.y - tabLT.y) + 20
		 
		@obj = canvas.rect x, y

if not window? then module.exports = Anchor
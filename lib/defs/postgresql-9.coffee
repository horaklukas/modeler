'use strict'

extend = require 'extend'

postgresql_8 = require './postgresql-8'
postgresql_8_last = postgresql_8[postgresql_8.length - 1]

postgresql_9_0 = {}
extend true, postgresql_9_0, postgresql_8_last
postgresql_9_0.version = '9.0'

postgresql_9_1 = {}
extend true, postgresql_9_1, postgresql_9_0
postgresql_9_1.version = '9.1'

postgresql_9_2 = {}
extend true, postgresql_9_2, postgresql_9_1
postgresql_9_2.version = '9.2'

# new types to existing categories
postgresql_9_2.types.numeric.push(
  'smallserial'						# serial2
)

postgresql_9_2.types.special.push(
  'json'
)

postgresql_9_3 = {}
extend true, postgresql_9_3, postgresql_9_2
postgresql_9_3.version = '9.3'

module.exports = [
	postgresql_9_0
	postgresql_9_1
	postgresql_9_2
	postgresql_9_3
]

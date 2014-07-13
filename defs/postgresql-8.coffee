'use strict'

extend = require 'extend'

postgresql_7 = require './postgresql-7'
postgresql_7_last = postgresql_7[postgresql_7.length - 1]

postgresql_8_0 = {}
extend true, postgresql_8_0, postgresql_7_last
postgresql_8_0.version = '8.0'

postgresql_8_1 = {}
extend true, postgresql_8_1, postgresql_8_0
postgresql_8_1.version = '8.1'

postgresql_8_2 = {}
extend true, postgresql_8_2, postgresql_8_1
postgresql_8_2.version = '8.2'

postgresql_8_3 = {}
extend true, postgresql_8_3, postgresql_8_2
postgresql_8_3.version = '8.3'

# new categories with new types
postgresql_8_3.types['text search'] = ['tsvector', 'tsquery']
postgresql_8_3.types['special'] = ['txid_snapshot', 'uuid', 'xml']

postgresql_8_4 = {}
extend true, postgresql_8_4, postgresql_8_3
postgresql_8_4.version = '8.4'

module.exports = [
	postgresql_8_0
	postgresql_8_1
	postgresql_8_2
	postgresql_8_3
	postgresql_8_4
]

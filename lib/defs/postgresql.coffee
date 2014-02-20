sql92Definition = require './sql92'
extend = require '../lib/extendDef'

postgreDefinition = 
	'name': 'PostgreSQL'
	'version':  '9.3'
	'types': 
		'string': [
			'text'
		]
		'numeric': [
			'bigint'
			'bigserial'
			'smallserial'
			'serial'
		]
		'datetime': [
			'date'
			'time'
			'time with time zone'
			'timestamp with time zone'
		]
		'geometric': [
			'box'
			'circle'
			'line'
			'lseg'
			'path'			
			'point'
			'polygon'
		]
		'network address': [
			'cidr'
			'inet'
			'macaddr'
		]
		'range': [
			'int4range'
			'int8range'
			'numrange'
			'tsrange'
			'tstzrange'
			'daterange'
		]
		'other': [
			'bytea'
			'boolean'
			'json'
			'money'
			'uuid'
			'xml'
		]

extendedSql92Definition = {types: {}}
extend extendedSql92Definition, sql92Definition
extend extendedSql92Definition, postgreDefinition

module.exports = extendedSql92Definition
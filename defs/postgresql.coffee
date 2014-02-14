sql92Definition = require './sql92'
extend = require 'extend'

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

extend true, postgreDefinition, sql92Definition

module.exports = postgreDefinition
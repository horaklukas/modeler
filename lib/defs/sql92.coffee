module.exports =
	'name': 'SQL'
	'version': '92'
	'types':
		'string': [
			'bit'						# not found at postgresql string types
			'bit varying'		# not found at postgresql string types
			'character'
			'varchar' #'character varying'
		]
		'numeric': [
			'decimal'
			'double precision'
			# This type not found at postgresql numeric types see
			# http://www.postgresql.org/docs/9.3/static/datatype-numeric.html
			#'float'
			'integer'
			'numeric'
			'real'
			'smallint'
		]
		'datetime': [
			'date'
			'time'
			'timestamp'
			'interval'
		]
		'other': [
		]
module.exports =
	'name': 'SQL'	
	'version': '92'
	'types':								 #  alias
		'numeric': [					 # =======	
			'numeric'
			'decimal'							
			'integer'
			'smallint'
			'float'
			'real'
			'double precision'
		]
		'string': [
			'bit'						
			'bit varying'		
			'character'						# char
			'character varying' 	# varchar
		]
		'datetime': [
			'date'
			'time'
			'timestamp'
			'interval'
		]
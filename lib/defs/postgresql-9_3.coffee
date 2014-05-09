module.exports = 
  'name': 'PostgreSQL'
  'version':  '9.3'
  'types':                  # aliases
    'numeric': [            # ======= 
      'smallint'            # int2
      'integer'             # int, int4
      'bigint'              # int8            
      'numeric'             # decimal
      'real'                # float4
      'double precision'    # float8
      'smallserial'         # serial2
      'serial'              # serial4
      'bigserial'           # serial8
    ]
    'monetary': [
      'money'
    ]
    'string': [
      'character'           # char
      'character varying'   # varchar
      'text'
    ]
    'binary': [
      'bytea'
    ]
    'datetime': [
      'timestamp'           # timestamptz
      'timestamp with time zone'
      'date'
      'time'                # timetz
      'time with time zone'
      'interval'
    ]
    'boolean': [
      'boolean'           # bool
    ]
    'geometric': [
      'point'
      'line'
      'lseg'
      'box'
      'path'      
      'polygon'
      'circle'
    ]
    'network address': [
      'cidr'
      'inet'
      'macaddr'
    ]
    'bit': [
      'bit'
      'bit varying'       # varbit
    ]
    'text search': [
      'tsvector'
      'tsquery'
    ]
    'special': [
      'uuid'
      'xml'
      'json'
    ]
    'range': [
      'int4range'
      'int8range'
      'numrange'
      'tsrange'
      'tstzrange'
      'daterange'
    ]

###
    'object identifier': [
      'oid'
      'regproc'
      'regprocedure'
      'regoper'
      'regopertor'
      'regclass'
      'regtype'
      'regconfig'
      'regdictionary'
    ]
###
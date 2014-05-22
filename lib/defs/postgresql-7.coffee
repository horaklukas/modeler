'use strict'

extend = require 'extend'

postgresql_7_1 = 
  'name': 'PostgreSQL'
  'version':  '7.1'
  'types':                  # aliases
    'numeric': [            # ======= 
      'smallint'            # int2
      'integer'             # int, int4
      'bigint'              # int8            
      'numeric'             # decimal
      'real'                # float4
      'double precision'    # float8
      'serial'              # serial4
    ]
    'monetary': [
      'money'
    ]
    'string': [
      'character'           # char
      'character varying'   # varchar
      'text'
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
    'special': [
      'oid'
    ]

postgresql_7_2 = {}
extend true, postgresql_7_2, postgresql_7_1
postgresql_7_2.version = '7.2'

# new types to existing categories
postgresql_7_2.types.numeric.push(
  'bigserial'           # serial8
)

# new categories with new types
postgresql_7_2.types.binary = ['bytea']

postgresql_7_3 = {}
extend true, postgresql_7_3, postgresql_7_2
postgresql_7_3.version = '7.3'

# deprecated types to be removed

# because `oid` was single type at category special, whole category can be
# deleted
delete postgresql_7_3.types.special

postgresql_7_4 = {}
extend true, postgresql_7_4, postgresql_7_3
postgresql_7_4.version = '7.4'

module.exports = [
  postgresql_7_1
  postgresql_7_2
  postgresql_7_3
  postgresql_7_4
]
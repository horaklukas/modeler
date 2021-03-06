pg = require 'pg'
exports.query = query = {}

DEFAULT_SCHEMA_NAME = 'public'

###*
* @param {Object.<string,(string|number|boolen)>} connOptions
* @return {pg.Client}
###
exports.getClient = (connOptions) ->
  new pg.Client({
    host: connOptions.host
    database: connOptions.db
    user: connOptions.user
    password: connOptions.pass ? null
    port: connOptions.port ? 5432
    ssl: connOptions.ssl ? false
  })

query.getDbServerVersion = ->
  """
  SELECT substring(version FROM '^PostgreSQL (\\d+\.\\d+)') AS version
  FROM version()
  """


query.getSchemata = ->
  # get all user schemata
  """
  SELECT schema_name FROM information_schema.schemata 
  WHERE schema_name != 'information_schema' 
  AND schema_name NOT LIKE 'pg_%';
  """

###*
* @return {string} name of default database schema
###
exports.getDefaultSchema = ->
  DEFAULT_SCHEMA_NAME

query.getTablesList = (schema) ->
	"""
	SELECT table_name FROM information_schema.tables
	WHERE table_schema = '#{schema}'
	"""

###*
* Returns query that select columns with passed type of constraint
*
* @param {string} schema Name of database schema to get data from
* @param {string} constr Name of constraint
* @param {?string=} typeAlias Name of constraint type column
* @param {string=} position Name of field that contain position to get. If not
*  passed, position should not been selected 
* @return {string} required query
###
query.getConstraintColumns = (schema, constr, typeAlias = 'type', position) ->
  localQuery =  
    """
    SELECT DISTINCT constrs.constraint_name, 
      keycols.column_name AS column,
      keycols.table_name AS table,
    """

  if position then localQuery += 
    """
      keycols.#{position} AS position,
    """

  localQuery +=
    """
      constrs.constraint_type AS #{typeAlias}
    FROM information_schema.key_column_usage AS keycols
    JOIN information_schema.table_constraints AS constrs 
      ON  keycols.constraint_name = constrs.constraint_name 
      AND keycols.table_name = constrs.table_name 
    WHERE constrs.constraint_type = '#{constr}'
      AND constrs.table_schema = '#{schema}'
    """

###*
* Returns query that select all columns from supplied schema, order by tables
*
* @param {string} schema Database schema to get tables and columns from
* @param {Array.<string>} tables
###
query.getTableColumns = (schema, tables) ->
  """
  SELECT 
    DISTINCT cols.table_name, cols.column_name, cols.data_type,
    CASE WHEN cols.is_nullable = 'YES' then false ELSE true END AS isNotNull,
    CASE WHEN pkcols.isPk = 'PRIMARY KEY' THEN true ELSE false END AS isPk,
    CASE WHEN uniqcols.isUnique = 'UNIQUE' THEN true ELSE false END AS isUnique,
    CASE WHEN fkcols.isFk= 'FOREIGN KEY' THEN true ELSE false END AS isFk,
    cols.ordinal_position AS position,
    cols.character_maximum_length AS length
  FROM information_schema.columns AS cols

  LEFT JOIN (
    #{query.getConstraintColumns(schema, 'PRIMARY KEY', 'isPk')}
  ) pkcols

  ON cols.column_name = pkcols.column AND cols.table_name = pkcols.table
  
  LEFT JOIN (
    #{query.getConstraintColumns(schema, 'UNIQUE', 'isUnique')}
  ) uniqcols
  
  ON cols.column_name = uniqcols.column AND cols.table_name = uniqcols.table
  
  LEFT JOIN (
    #{query.getConstraintColumns(schema, 'FOREIGN KEY', 'isFk')}
  ) fkcols
  
  ON cols.column_name = fkcols.column AND cols.table_name = fkcols.table
  
  WHERE cols.table_schema = '#{schema}'
  AND cols.table_name IN ('#{tables.join("','")}')
  ORDER BY cols.table_name, position
  """

###*
* Returns query that select foreign key columns and their corresponding primary
* key columns
*
* @param {string} schema Database schema to get tables and columns from
* @param {Array.<string>} tables
###

query.getRelations = (schema, tables = []) ->
  """  
  SELECT
    refs.constraint_name AS name,
    parentcols.table AS parent_table,
    parentcols.column AS parent_column,
    childcols.table AS child_table,
    childcols.column AS child_column,
    CASE WHEN childcolspks.isPk IS NULL THEN false ELSE true END AS is_identifying
  FROM ( 
    #{query.getConstraintColumns(schema, 'FOREIGN KEY', null, 'position_in_unique_constraint')}
  ) childcols

  LEFT JOIN (
    #{query.getConstraintColumns(schema, 'PRIMARY KEY', 'isPk')}
  ) childcolspks

  ON childcols.table = childcolspks.table 
  AND childcols.column = childcolspks.column

  JOIN (
    SELECT constraint_name, unique_constraint_name 
    FROM information_schema.referential_constraints 
    WHERE constraint_schema = 'public'
  ) refs

  ON childcols.constraint_name = refs.constraint_name

  JOIN (
    #{query.getConstraintColumns(schema, 'PRIMARY KEY', null, 'ordinal_position')}    
  ) parentcols

  ON refs.unique_constraint_name = parentcols.constraint_name
  WHERE parentcols.position = childcols.position
  AND parentcols.table in ('#{tables.join("','")}')
  AND childcols.table in ('#{tables.join("','")}')
  ORDER BY parent_table, child_table
  """
###*
* Returns query that select columns with passed type of constraint
*
* @param {string} constr Name of constraint
* @param {string} alias Name of constraint query
* @return {string} required query
###
getConstraintColumns = (constr, alias) ->
  """
  SELECT DISTINCT keycols.column_name AS column,
    keycols.table_name AS table,
    constrs.constraint_type AS #{alias}
  FROM information_schema.key_column_usage AS keycols
  JOIN information_schema.table_constraints AS constrs 
  ON  keycols.constraint_name = constrs.constraint_name 
  AND keycols.table_name = constrs.table_name 
  WHERE constrs.constraint_type = '#{constr}'
  """

###*
* Returns query that select all columns from supplied schema, order by tables
*
* @param {string} schema Database schema to get tables and columns from
###
exports.getTableColumns = (schema) ->
  """
  SELECT DISTINCT cols.table_name, cols.column_name, cols.data_type,
  CASE WHEN cols.is_nullable = 'YES' then false ELSE true END AS isNotNull,
  CASE WHEN pkcols.isPk = 'PRIMARY KEY' THEN true ELSE false END AS isPk,
  CASE WHEN uniqcols.isUnique = 'UNIQUE' THEN true ELSE false END AS isUnique,
  CASE WHEN fkcols.isFk= 'FOREIGN KEY' THEN true ELSE false END AS isFk
  FROM information_schema.columns AS cols
  LEFT JOIN (
    #{getConstraintColumns('PRIMARY KEY', 'isPk')}
  ) pkcols
  ON cols.column_name = pkcols.column AND cols.table_name = pkcols.table
  LEFT JOIN (
    #{getConstraintColumns('UNIQUE', 'isUnique')}
  ) uniqcols
  ON cols.column_name = uniqcols.column AND cols.table_name = uniqcols.table
    LEFT JOIN (
    #{getConstraintColumns('FOREIGN KEY', 'isFk')}
  ) fkcols
  ON cols.column_name = fkcols.column AND cols.table_name = fkcols.table
  WHERE cols.table_schema = '#{schema}'
  ORDER BY cols.table_name
  """

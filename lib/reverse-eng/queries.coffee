###*
* Returns query that select columns with passed type of constraint
*
* @param {string} schema Name of database schema to get data from
* @param {string} constr Name of constraint
* @param {string} typeAlias Name of constraint type column
* @return {string} required query
###
getConstraintColumns = (schema, constr, typeAlias = 'type') ->
  """
  SELECT DISTINCT constrs.constraint_name, 
    keycols.column_name AS column,
    keycols.table_name AS table,
    constrs.constraint_type AS #{typeAlias}
  FROM information_schema.key_column_usage AS keycols
  JOIN information_schema.table_constraints AS constrs 
    ON  keycols.constraint_name = constrs.constraint_name 
    AND keycols.table_name = constrs.table_name 
  WHERE constrs.constraint_type = '#{constr}'
    AND constrs.table_schema = 'public'
  """

###*
* Returns query that select all columns from supplied schema, order by tables
*
* @param {string} schema Database schema to get tables and columns from
###
exports.getTableColumns = (schema) ->
  """
  SELECT 
    DISTINCT cols.table_name, cols.column_name, cols.data_type,
    CASE WHEN cols.is_nullable = 'YES' then false ELSE true END AS isNotNull,
    CASE WHEN pkcols.isPk = 'PRIMARY KEY' THEN true ELSE false END AS isPk,
    CASE WHEN uniqcols.isUnique = 'UNIQUE' THEN true ELSE false END AS isUnique,
    CASE WHEN fkcols.isFk= 'FOREIGN KEY' THEN true ELSE false END AS isFk
  FROM information_schema.columns AS cols

  LEFT JOIN (
    #{getConstraintColumns(schema, 'PRIMARY KEY', 'isPk')}
  ) pkcols

  ON cols.column_name = pkcols.column AND cols.table_name = pkcols.table
  
  LEFT JOIN (
    #{getConstraintColumns(schema, 'UNIQUE', 'isUnique')}
  ) uniqcols
  
  ON cols.column_name = uniqcols.column AND cols.table_name = uniqcols.table
  
  LEFT JOIN (
    #{getConstraintColumns(schema, 'FOREIGN KEY', 'isFk')}
  ) fkcols
  
  ON cols.column_name = fkcols.column AND cols.table_name = fkcols.table
  
  WHERE cols.table_schema = '#{schema}'
  ORDER BY cols.table_name
  """

###*
* Returns query that select foreign key columns and their corresponding primary
* key columns
*
* @param {string} schema Database schema to get tables and columns from
###

exports.getRelations = (schema) ->
  """  
  SELECT
    childcols.table AS Child_table,
    childcols.column AS Child_column,
    parentcols.table AS Parent_table,
    parentcols.column AS Parent_column,
    CASE WHEN childcolspks.isPk IS NULL THEN false ELSE true END AS is_identifying
  FROM ( 
    #{getConstraintColumns(schema, 'FOREIGN KEY')}
  ) childcols

  LEFT JOIN (
    #{getConstraintColumns(schema, 'PRIMARY KEY', 'isPk')}
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
    #{getConstraintColumns(schema, 'PRIMARY KEY')}    
  ) parentcols

  ON refs.unique_constraint_name = parentcols.constraint_name;
  """
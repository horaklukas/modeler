var rel1, rel1model, rel2, rel2model, rel3, rel3model, rel4, rel4model, tab0, tab0model, tab1, tab1model, tab2, tab2model, tab3, tab3model, tab4, tab4model, tab5, tab5model;

tab0model = new dm.model.Table('Person', [
  {
    name: 'person_id',
    type: 'smallint',
    isPk: true,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'name',
    type: 'varchar',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }
]);

tab0 = new dm.ui.Table(tab0model, 100, 75);

tab1model = new dm.model.Table('Account', [
  {
    name: 'account_id',
    type: 'smallint',
    isPk: true,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'account_number',
    type: 'numeric',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }
]);

tab1 = new dm.ui.Table(tab1model, 500, 280);

tab2model = new dm.model.Table('PersonAccount');

tab2 = new dm.ui.Table(tab2model, 100, 280);

tab3model = new dm.model.Table('AccountType', [
  {
    name: 'acctype_id',
    type: 'smallint',
    isPk: true,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'code',
    type: 'numeric',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'name',
    type: 'varchar',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'description',
    type: 'varchar',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }
]);

tab3 = new dm.ui.Table(tab3model, 600, 50);

tab4model = new dm.model.Table('BigSizeTable', [
  {
    name: 'first_long_pk_column',
    type: 'smallint',
    isPk: true,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'second_long_row',
    type: 'numeric',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'third_row_that_is_long',
    type: 'numeric',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'description',
    type: 'varchar',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'code_long',
    type: 'numeric',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'name_of_this_row',
    type: 'varchar',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }
]);

tab4 = new dm.ui.Table(tab4model, 900, 50);

tab5model = new dm.model.Table('SecondBigSizeTable', [
  {
    name: 'first_long_pk_column',
    type: 'smallint',
    isPk: true,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'second_long_row',
    type: 'numeric',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'third_row_that_is_long',
    type: 'numeric',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'description',
    type: 'varchar',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'code_long',
    type: 'numeric',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }, {
    name: 'name_of_this_row',
    type: 'varchar',
    isPk: false,
    isNotNull: false,
    isUnique: false
  }
]);

tab5 = new dm.ui.Table(tab5model, 900, 250);

canvas.addTable(tab0);

canvas.addTable(tab1);

canvas.addTable(tab2);

canvas.addTable(tab3);

canvas.addTable(tab4);

canvas.addTable(tab5);

/*
tab0 = dm.actualModel.addTable canvas.html, 100, 75
dm.actualModel.setTable tab0, 'Person', [
	new dm.model.TableColumn 'person_id', 'smallint', true
	new dm.model.TableColumn 'name', 'character varying'
]

tab1 = dm.actualModel.addTable canvas.html, 500, 280
dm.actualModel.setTable tab1, 'Account', [
	new dm.model.TableColumn 'account_id', 'smallint', true
	new dm.model.TableColumn 'account_number', 'numeric'
]

tab2 = dm.actualModel.addTable canvas.html, 100, 280
dm.actualModel.setTable tab2, 'PersonAccount'

tab3 = dm.actualModel.addTable canvas.html, 600, 50
dm.actualModel.setTable tab3, 'AccountType', [
	new dm.model.TableColumn 'acctype_id', 'smallint', true
	new dm.model.TableColumn 'code', 'numeric'
	new dm.model.TableColumn 'name', 'character varying'
	new dm.model.TableColumn 'description', 'character varying'
]

tab4 = dm.actualModel.addTable canvas.html, 900, 50
dm.actualModel.setTable tab4, 'BigSizeTable', [
	new dm.model.TableColumn 'first_long_pk_column', 'smallint', true
	new dm.model.TableColumn 'second_long_row', 'numeric'
	new dm.model.TableColumn 'third_row_that_is_long', 'numeric'
	new dm.model.TableColumn 'description', 'character varying'	
	new dm.model.TableColumn 'code_long', 'numeric'
	new dm.model.TableColumn 'name_of_this_row', 'character varying'
]	

tab5 = dm.actualModel.addTable canvas.html, 900, 250
dm.actualModel.setTable tab5, 'SecondBigSizeTable', [
	new dm.model.TableColumn 'first_long_pk_column', 'smallint', true
	new dm.model.TableColumn 'second_long_row', 'numeric'
	new dm.model.TableColumn 'third_row_that_is_long', 'numeric'
	new dm.model.TableColumn 'description', 'character varying'	
	new dm.model.TableColumn 'code_long', 'numeric'
	new dm.model.TableColumn 'name_of_this_row', 'character varying'
]
*/


rel1model = new dm.model.Relation(true);

rel1 = new dm.ui.Relation(rel1model, tab0, tab2);

rel2model = new dm.model.Relation(true);

rel2 = new dm.ui.Relation(rel2model, tab1, tab2);

rel3model = new dm.model.Relation(false);

rel3 = new dm.ui.Relation(rel3model, tab1, tab3);

rel4model = new dm.model.Relation(false);

rel4 = new dm.ui.Relation(rel4model, tab4, tab5);

canvas.addRelation(rel1);

canvas.addRelation(rel2);

canvas.addRelation(rel3);

canvas.addRelation(rel4);

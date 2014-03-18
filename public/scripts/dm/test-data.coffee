# Some test tables and relations
###tab0model = new dm.model.Table 'Person', [
	{ name:'person_id', type:'smallint', isNotNull:false }
	{ name:'name', type:'varchar', isNotNull:false }
]
tab0model.setIndex 0, dm.model.Table.index.PK
tab0 = dm.addTable tab0model, 100, 75

tab1model = new dm.model.Table 'Account', [
	{ name:'account_id', type:'smallint', isNotNull:false }
	{ name:'account_number', type:'numeric', isNotNull:false }
]
tab1model.setIndex 0, dm.model.Table.index.PK
tab1 = dm.addTable tab1model, 500, 280

tab2model = new dm.model.Table 'PersonAccount'
tab2 = dm.addTable tab2model, 100, 280

tab3model = new dm.model.Table 'AccountType', [
	{ name:'acctype_id', type:'smallint', isNotNull:false }
	{ name:'code', type:'numeric', isNotNull:false }
	{ name:'name', type:'varchar', isNotNull:false }
	{ name:'description', type:'varchar', isNotNull:false }
]
tab3model.setIndex 0, dm.model.Table.index.PK
tab3 = dm.addTable tab3model, 600, 50

tab4model = new dm.model.Table 'BigSizeTable', [
	{ name:'first_long_pk_column', type:'smallint', isNotNull:false }
	{ name:'second_long_row', type:'numeric', isNotNull:false }
	{ name:'third_row_that_is_long', type:'numeric', isNotNull:false }
	{ name:'description', type:'varchar', isNotNull:false }
	{ name:'code_long', type:'numeric', isNotNull:false }
	{ name:'name_of_this_row', type:'varchar', isNotNull:false }
]	
tab4model.setIndex 0, dm.model.Table.index.PK
tab4 = dm.addTable tab4model, 900, 50

tab5model = new dm.model.Table 'SecondBigSizeTable', [
	{ name:'first_long_pk_column', type:'smallint', isNotNull:false }
	{ name:'second_long_row', type:'numeric', isNotNull:false }
	{ name:'third_row_that_is_long', type:'numeric', isNotNull:false }
	{ name:'description', type:'varchar', isNotNull:false }
	{ name:'code_long', type:'numeric', isNotNull:false }
	{ name:'name_of_this_row', type:'varchar', isNotNull:false }
]
tab5model.setIndex 0, dm.model.Table.index.PK
tab5 = dm.addTable tab5model, 900, 250

tab6model = new dm.model.Table 'ParentTable', [
	{ name:'parent_id', type:'integer', isNotNull:false }
]
tab6model.setIndex 0, dm.model.Table.index.PK
tab6 = dm.addTable tab6model, 250, 400

tab7model = new dm.model.Table 'ChildTable', [
	{ name:'child_id', type:'integer', isNotNull:false }
	{ name: 'unique_column', type: 'varchar', isNotNull: false }
]
tab7model.setIndex 0, dm.model.Table.index.PK
tab7model.setIndex 1, dm.model.Table.index.UNIQUE
tab7 = dm.addTable tab7model, 450, 400

tab8model = new dm.model.Table 'ParentTableOfParent', [
	{ name:'parentofparent_id', type:'integer', isNotNull:false }
	{ name: 'not_null_column', type: 'varchar', isNotNull: true}
]
tab8model.setIndex 0, dm.model.Table.index.PK
tab8 = dm.addTable tab8model, 250, 600

tab9model = new dm.model.Table 'ParentTableOfParent2', [
	{ name:'parentofparent2_id', type:'integer', isNotNull:false }
	{ name:'parentofparent2_id2', type:'integer', isNotNull:false }
	{ name: 'ordinary_column', type: 'date', isNotNull: false}
]
tab9model.setIndex 0, dm.model.Table.index.PK
tab9model.setIndex 1, dm.model.Table.index.PK
tab9 = dm.addTable tab9model, 50, 600

rel1model = new dm.model.Relation true 
dm.addRelation rel1model, tab0, tab2

rel2model = new dm.model.Relation true
dm.addRelation rel2model, tab1, tab2

rel3model = new dm.model.Relation false
dm.addRelation rel3model, tab1, tab3

rel4model = new dm.model.Relation false
dm.addRelation rel4model, tab4, tab5

rel5model = new dm.model.Relation false
dm.addRelation rel5model, tab6, tab7

rel6model = new dm.model.Relation false
dm.addRelation rel6model, tab8, tab6

rel7model = new dm.model.Relation false
dm.addRelation rel7model, tab9, tab6
###
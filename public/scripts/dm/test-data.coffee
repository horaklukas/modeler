# Some test objects
tab0model = new dm.model.Table 'Person', [
	{ name:'person_id', type:'smallint', isNotNull:false }
	{ name:'name', type:'varchar', isNotNull:false }
]
tab0model.setIndex 0, dm.model.Table.index.PK
tab0 = new dm.ui.Table tab0model, 100, 75

tab1model = new dm.model.Table 'Account', [
	{ name:'account_id', type:'smallint', isNotNull:false }
	{ name:'account_number', type:'numeric', isNotNull:false }
]
tab1model.setIndex 0, dm.model.Table.index.PK
tab1 = new dm.ui.Table tab1model, 500, 280

tab2model = new dm.model.Table 'PersonAccount'
tab2 = new dm.ui.Table tab2model, 100, 280

tab3model = new dm.model.Table 'AccountType', [
	{ name:'acctype_id', type:'smallint', isNotNull:false }
	{ name:'code', type:'numeric', isNotNull:false }
	{ name:'name', type:'varchar', isNotNull:false }
	{ name:'description', type:'varchar', isNotNull:false }
]
tab3model.setIndex 0, dm.model.Table.index.PK
tab3 = new dm.ui.Table tab3model, 600, 50

tab4model = new dm.model.Table 'BigSizeTable', [
	{ name:'first_long_pk_column', type:'smallint', isNotNull:false }
	{ name:'second_long_row', type:'numeric', isNotNull:false }
	{ name:'third_row_that_is_long', type:'numeric', isNotNull:false }
	{ name:'description', type:'varchar', isNotNull:false }
	{ name:'code_long', type:'numeric', isNotNull:false }
	{ name:'name_of_this_row', type:'varchar', isNotNull:false }
]	
tab4model.setIndex 0, dm.model.Table.index.PK
tab4 = new dm.ui.Table tab4model, 900, 50

tab5model = new dm.model.Table 'SecondBigSizeTable', [
	{ name:'first_long_pk_column', type:'smallint', isNotNull:false }
	{ name:'second_long_row', type:'numeric', isNotNull:false }
	{ name:'third_row_that_is_long', type:'numeric', isNotNull:false }
	{ name:'description', type:'varchar', isNotNull:false }
	{ name:'code_long', type:'numeric', isNotNull:false }
	{ name:'name_of_this_row', type:'varchar', isNotNull:false }
]
tab5model.setIndex 0, dm.model.Table.index.PK
tab5 = new dm.ui.Table tab5model, 900, 250

tab6model = new dm.model.Table 'ParentTable', [
	{ name:'parent_id', type:'integer', isNotNull:false }
]
tab6model.setIndex 0, dm.model.Table.index.PK
tab6 = new dm.ui.Table tab6model, 250, 400

tab7model = new dm.model.Table 'ChildTable', [
	{ name:'child_id', type:'integer', isNotNull:false }
	{ name: 'unique_column', type: 'varchar', isNotNull: false }
]
tab7model.setIndex 0, dm.model.Table.index.PK
tab7model.setIndex 1, dm.model.Table.index.UNIQUE
tab7 = new dm.ui.Table tab7model, 450, 400

tab8model = new dm.model.Table 'ParentTableOfParent', [
	{ name:'parentofparent_id', type:'integer', isNotNull:false }
	{ name: 'not_null_column', type: 'varchar', isNotNull: true}
]
tab8model.setIndex 0, dm.model.Table.index.PK
tab8 = new dm.ui.Table tab8model, 250, 600

tab9model = new dm.model.Table 'ParentTableOfParent2', [
	{ name:'parentofparent2_id', type:'integer', isNotNull:false }
	{ name:'parentofparent2_id2', type:'integer', isNotNull:false }
	{ name: 'ordinary_column', type: 'date', isNotNull: false}
]
tab9model.setIndex 0, dm.model.Table.index.PK
tab9model.setIndex 1, dm.model.Table.index.PK
tab9 = new dm.ui.Table tab9model, 50, 600

canvas.addTable tab0
canvas.addTable tab1
canvas.addTable tab2
canvas.addTable tab3
canvas.addTable tab4
canvas.addTable tab5
canvas.addTable tab6
canvas.addTable tab7
canvas.addTable tab8
canvas.addTable tab9

rel1model = new dm.model.Relation true 
rel1 = new dm.ui.Relation rel1model
rel1.setRelatedTables tab0, tab2
rel2model = new dm.model.Relation true
rel2 = new dm.ui.Relation rel2model
rel2.setRelatedTables tab1, tab2
rel3model = new dm.model.Relation false
rel3 = new dm.ui.Relation rel3model
rel3.setRelatedTables tab1, tab3
rel4model = new dm.model.Relation false
rel4 = new dm.ui.Relation rel4model
rel4.setRelatedTables tab4, tab5
rel5model = new dm.model.Relation false
rel5 = new dm.ui.Relation rel5model
rel5.setRelatedTables tab6, tab7
rel6model = new dm.model.Relation false
rel6 = new dm.ui.Relation rel6model
rel6.setRelatedTables tab8, tab6
rel7model = new dm.model.Relation false
rel7 = new dm.ui.Relation rel7model
rel7.setRelatedTables tab9, tab6

canvas.addRelation rel1 
canvas.addRelation rel2 
canvas.addRelation rel3 
canvas.addRelation rel4 
canvas.addRelation rel5
canvas.addRelation rel6
canvas.addRelation rel7
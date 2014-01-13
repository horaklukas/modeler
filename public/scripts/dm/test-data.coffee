# Some test objects
tab0model = new dm.model.Table 'Person', [
	{ name:'person_id', type:'smallint', isPk:true, isNotNull:false, isUnique:false }
	{ name:'name', type:'varchar', isPk:false, isNotNull:false, isUnique:false }
]
tab0 = new dm.ui.Table tab0model, 100, 75

tab1model = new dm.model.Table 'Account', [
	{ name:'account_id', type:'smallint', isPk:true, isNotNull:false, isUnique: false }
	{ name:'account_number', type:'numeric', isPk:false, isNotNull:false, isUnique: false }
]
tab1 = new dm.ui.Table tab1model, 500, 280

tab2model = new dm.model.Table 'PersonAccount'
tab2 = new dm.ui.Table tab2model, 100, 280

tab3model = new dm.model.Table 'AccountType', [
	{ name:'acctype_id', type:'smallint', isPk:true, isNotNull:false, isUnique: false }
	{ name:'code', type:'numeric', isPk:false, isNotNull:false, isUnique:false }
	{ name:'name', type:'varchar', isPk:false, isNotNull:false, isUnique: false }
	{ name:'description', type:'varchar', isPk:false, isNotNull:false, isUnique: false }
]
tab3 = new dm.ui.Table tab3model, 600, 50

tab4model = new dm.model.Table 'BigSizeTable', [
	{ name:'first_long_pk_column', type:'smallint', isPk:true, isNotNull:false, isUnique:false }
	{ name:'second_long_row', type:'numeric', isPk:false, isNotNull:false, isUnique:false }
	{ name:'third_row_that_is_long', type:'numeric', isPk:false, isNotNull:false, isUnique:false }
	{ name:'description', type:'varchar', isPk:false, isNotNull:false, isUnique:false }
	{ name:'code_long', type:'numeric', isPk:false, isNotNull:false, isUnique:false }
	{ name:'name_of_this_row', type:'varchar', isPk:false, isNotNull:false, isUnique:false }
]	
tab4 = new dm.ui.Table tab4model, 900, 50

tab5model = new dm.model.Table 'SecondBigSizeTable', [
	{ name:'first_long_pk_column', type:'smallint', isPk:true, isNotNull:false, isUnique:false }
	{ name:'second_long_row', type:'numeric', isPk:false, isNotNull:false, isUnique:false }
	{ name:'third_row_that_is_long', type:'numeric', isPk:false, isNotNull:false, isUnique:false }
	{ name:'description', type:'varchar', isPk:false, isNotNull:false, isUnique:false }
	{ name:'code_long', type:'numeric', isPk:false, isNotNull:false, isUnique:false }
	{ name:'name_of_this_row', type:'varchar', isPk:false, isNotNull:false, isUnique:false }
]
tab5 = new dm.ui.Table tab5model, 900, 250

tab6model = new dm.model.Table 'ParentTable', [
	{ name:'parent_id', type:'integer', isPk:true, isNotNull:false, isUnique:false }
]
tab6 = new dm.ui.Table tab6model, 250, 100

tab7model = new dm.model.Table 'ChildTable', [
	{ name:'child_id', type:'integer', isPk:true, isNotNull:false, isUnique:false }
]
tab7 = new dm.ui.Table tab7model, 450, 100

canvas.addTable tab0
canvas.addTable tab1
canvas.addTable tab2
canvas.addTable tab3
canvas.addTable tab4
canvas.addTable tab5
canvas.addTable tab6
canvas.addTable tab7

rel1model = new dm.model.Relation true 
rel1 = new dm.ui.Relation rel1model, tab0, tab2
rel1.setRelatedTablesKeys()
rel2model = new dm.model.Relation true
rel2 = new dm.ui.Relation rel2model, tab1, tab2
rel2.setRelatedTablesKeys()
rel3model = new dm.model.Relation false
rel3 = new dm.ui.Relation rel3model, tab1, tab3
rel3.setRelatedTablesKeys()
rel4model = new dm.model.Relation false
rel4 = new dm.ui.Relation rel4model, tab4, tab5
rel4.setRelatedTablesKeys()

canvas.addRelation rel1 
canvas.addRelation rel2 
canvas.addRelation rel3 
canvas.addRelation rel4 
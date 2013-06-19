# IN DEVELOPMENT

## DEMO 

_The uploaded application needn't corespond to last state_

[Demo on Heroku](http://desolate-peak-6141.herokuapp.com/) 

## WORK PLAN
1. Frontend modeler part
	* creating table and relation objects	_in progress_
	* making table structure by selected database type
2. Backend modeler part
  * reingeneering of tables and relations from database
  * _possiblly creating of tables and relations from  database catalog_
3. Managment of models part
	* making image snapshoots from models
	* versioning of models
	* creation of packages to distribute model eg. as mail attachment


## TODO

### Table
* column indexes (unique, not null)
* <s> __resolve marking table as a group, eg. for detecting if clicked on 
  table__ possible solution is creating tables as div elements, next the
  svg and svg use for drawing relations</s>
* <s>Add text input to table head for typing table name right after create it
  </s>
* <s>dont allow to move table outside canvas</s>
* <s>change mouse cursor type to four-arrow when moving table</s>
* create system of counting best point to connect relation

### Relation
* multiple relations on same table side
* types of relation - identifying, non-identifyig
* <s>create new object - relationship between tables</s>
* cancel creating of relation if second point not defined
* <s>fix the problem of uncomplete relation when table is at bottom of canvas
</s> _probably happens, when size of canvas changes, eg. when resizing Chrome
 developer console_
* <s>get the relation between tables broken instead of straight</s>
* fix not disabled opossite points when counting path connection points

### Model
* <s>create object that holds actual model - its table and relations</s>
* <s>holds methods for placing object to canvas</s>

### Control Panel
* <s>__fix error when select activated tool once again__</s>
* <s>fix tools icons to be exclusive</s>

### <s>Anchor</s> _object canceled_
* <s>set right coordinates of anchor, in depend on its position</s>
* <s>create anchor test with mocked canvas</s>
* <s>move anchors when moving table</s>

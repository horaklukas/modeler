# IN DEVELOPMENT

## DEMO 

_The uploaded application needn't corespond to latest state_

[Demo on Heroku](http://db-modeler.herokuapp.com/) 

## WORK PLAN
1. Frontend modeler part
  * creating table and relation objects
  * making table structure by selected database type
2. Backend modeler part
  * reingeneering of tables and relations from database
3. Managment of models part
  * making image snapshoots from models
  * versioning of models
  * creation of packages to distribute model eg. as mail attachment

## TODO

### App
* <s>options to delete objects (tables/relations)</s>
* <s>create database connections manager</s>
* <s>add reingeneering of model from database</s>
* <s>add load/save model funcionality</s>

### Table
* <s>Fix changing columns at relation and table model when some column is deleted</s>
* create system of counting best point to connect relation
* <s>column indexes (unique, not null)</s>
* <s>change mouse cursor type to `move` when moving table - as listed out  in
[this topic](http://stackoverflow.com/questions/8942805/chrome-bug-cursor-changes-on-mouse-down-move/), for absolute positioned elements at chrome it may be impossible</s>
* <s>fix positions of relation endpoints</s>
* <s> __resolve marking table as a group, eg. for detecting if clicked on 
  table__ possible solution is creating tables as div elements, next the
  svg and svg use for drawing relations</s>
* <s>Add text input to table head for typing table name right after create it
  </s>
* <s>dont allow to move table outside canvas</s>

### Relation
* fix not disabled opossite points when counting path connection points
* <s>"unary relation" is relation from table to the same table </s>
* <s>fix propagating name of table to relation model if table name change</s>
* <s>multiple relations on same table side</s> resolved with direct realtions
* <s>types of relation - identifying, non-identifyig</s>
* <s>cancel creating of relation if second point not defined</s>
* <s>create new object - relationship between tables</s>
* <s>fix the problem of uncomplete relation when table is at bottom of canvas
</s> _probably happens, when size of canvas changes, eg. when resizing Chrome
 developer console_
* get the relation between tables broken instead of straight - this maybe won't
  be required

### Dialogs
* <s>Create "input model name" dialog</s>

#### Reeng dialog
* <s>add "check all" option</s>

#### Table dialog
* <s>Column's length attribute</s>
* Column's auto increment option
* <s>Fix creating of tables with same names</s>
* <s>fix lost of unsaved columns change when new column row is added</s>
* <s>fix allow confirm if table name not filled</s>
* <s>make columns creted by relation not deletable and editable (only name can
  change)</s>

### Model
* <s>create autodesigner that space out objects held as the data</s>
* remove unnecessary data  generated with `toJSON` method 
* <s>create object that holds actual model - its table and relations</s>
* <s>holds methods for placing object to canvas</s>

### Control Panel
* <s>__fix error when select activated tool once again__</s>
* <s>fix tools icons to be exclusive</s>

### Canvas
* creating of table or relation by select item at canvas contextmenu
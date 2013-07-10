# IN DEVELOPMENT

## DEMO 

_The uploaded application needn't corespond to latest state_

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
* create system of counting best point to connect relation
* change mouse cursor type to `move` when moving table - as listed out  in
[this topic](http://stackoverflow.com/questions/8942805/chrome-bug-cursor-changes-on-mouse-down-move/), for absolute positioned elements at chrome it may be impossible
* <s>fix positions of relation endpoints</s>
* <s> __resolve marking table as a group, eg. for detecting if clicked on 
  table__ possible solution is creating tables as div elements, next the
  svg and svg use for drawing relations</s>
* <s>Add text input to table head for typing table name right after create it
  </s>
* <s>dont allow to move table outside canvas</s>

### Relation
* multiple relations on same table side
* types of relation - identifying, non-identifyig
* fix not disabled opossite points when counting path connection points
* cancel creating of relation if second point not defined
* <s>create new object - relationship between tables</s>
* <s>fix the problem of uncomplete relation when table is at bottom of canvas
</s> _probably happens, when size of canvas changes, eg. when resizing Chrome
 developer console_
* <s>get the relation between tables broken instead of straight</s>

### Model
* create autodesigner that space out objects hold as the data
* <s>create object that holds actual model - its table and relations</s>
* <s>holds methods for placing object to canvas</s>

### Control Panel
* <s>__fix error when select activated tool once again__</s>
* <s>fix tools icons to be exclusive</s>

### <s>Anchor</s> _object canceled_
* <s>set right coordinates of anchor, in depend on its position</s>
* <s>create anchor test with mocked canvas</s>
* <s>move anchors when moving table</s>

## Google Closure build
**dependencies**
python /srv/git/modeler/public/scripts/lib/closure/bin/build/depswriter.py --root_with_prefix="/srv/git/modeler/public/scripts ../../.." --output_file /srv/git/modeler/public/scripts/app-deps.js

**templates**
java -jar /srv/www/GoogleClosure/templates/SoyCompiler/SoyToJsSrcCompiler.jar --outputPathFormat {INPUT_DIRECTORY}/{INPUT_FILE_NAME_NO_EXT}.js --shouldGenerateJsdoc --shouldProvideRequireSoyNamespaces --srcs /srv/git/modeler/public/scripts/templates/dialogs/createTable.soy,/srv/git/modeler/public/scripts/templates/model/table.soy
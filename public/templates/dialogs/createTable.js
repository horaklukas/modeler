// This file was automatically generated from createTable.soy.
// Please don't edit this file by hand.

if (typeof tmpls == 'undefined') { var tmpls = {}; }
if (typeof tmpls.dialogs == 'undefined') { tmpls.dialogs = {}; }
if (typeof tmpls.dialogs.createTable == 'undefined') { tmpls.dialogs.createTable = {}; }


tmpls.dialogs.createTable.dialog = function(opt_data, opt_ignored) {
  return '<div id="createTable" class="dialog">' + tmpls.dialogs.createTable.name({id: 'physical', label: 'Physical'}) + '<strong>Columns</strong>' + tmpls.dialogs.createTable.columnsList(opt_data) + '<button class="ok">OK</button><button class="cancel">CANCEL</button></div>';
};


tmpls.dialogs.createTable.name = function(opt_data, opt_ignored) {
  return '\t<div class="row"><span><label>' + soy.$$escapeHtml(opt_data.label) + ' name</label></span><span><input name="' + soy.$$escapeHtml(opt_data.id) + '_name" /></span></div>';
};


tmpls.dialogs.createTable.columnsList = function(opt_data, opt_ignored) {
  var output = '<div id="columns_list"><button>Add column</button><div class="row head"><span>Name</span><span>Type</span><span>PK</span><span></span></div>' + tmpls.dialogs.createTable.tableColumn(opt_data);
  if (opt_data.columns) {
    var columnList22 = opt_data.columns;
    var columnListLen22 = columnList22.length;
    for (var columnIndex22 = 0; columnIndex22 < columnListLen22; columnIndex22++) {
      var columnData22 = columnList22[columnIndex22];
      output += tmpls.dialogs.createTable.tableColumn({name: columnData22.name, types: opt_data.types, pkey: columnData22.pkey});
    }
  }
  output += '</div>';
  return output;
};


tmpls.dialogs.createTable.tableColumn = function(opt_data, opt_ignored) {
  var output = '<div class="row"><span><input type="text" name="name" value="' + ((opt_data.name) ? soy.$$escapeHtml(opt_data.name) : '') + '"/></span><span><select name="type">';
  var typeList35 = opt_data.types;
  var typeListLen35 = typeList35.length;
  for (var typeIndex35 = 0; typeIndex35 < typeListLen35; typeIndex35++) {
    var typeData35 = typeList35[typeIndex35];
    output += '<option value="' + soy.$$escapeHtml(typeData35) + '" ' + ((opt_data.colType == typeData35) ? 'selected' : '') + '>' + soy.$$escapeHtml(typeData35) + '</option>';
  }
  output += '</select></span><span><input type="checkbox" class="pkey" ' + ((opt_data.pkey == true) ? 'checked' : '') + ' /></span><span><button class="delete">Del</button></span></div>';
  return output;
};

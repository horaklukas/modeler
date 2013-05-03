// This file was automatically generated from table.soy.
// Please don't edit this file by hand.

if (typeof tmpls == 'undefined') { var tmpls = {}; }
if (typeof tmpls.components == 'undefined') { tmpls.components = {}; }
if (typeof tmpls.components.model == 'undefined') { tmpls.components.model = {}; }


tmpls.components.model.table = function(opt_data, opt_ignored) {
  return '<div class="table" id="' + soy.$$escapeHtml(opt_data.id) + '"><span class="head"></span><div class="body"></div></div>';
};


tmpls.components.model.tabColumns = function(opt_data, opt_ignored) {
  var output = '\t';
  var colList8 = opt_data.cols;
  var colListLen8 = colList8.length;
  for (var colIndex8 = 0; colIndex8 < colListLen8; colIndex8++) {
    var colData8 = colList8[colIndex8];
    output += tmpls.components.model.tabColumn({name: colData8.name, pk: colData8.pk});
  }
  return output;
};


tmpls.components.model.tabColumn = function(opt_data, opt_ignored) {
  return '<div><span>' + soy.$$escapeHtml(opt_data.name) + '</span>' + ((opt_data.pk) ? '<span class="idx">PK</span>' : '') + '</div>';
};

var Model;

Model = (function() {

  function Model(name) {
    if (!name) throw new Error('Model name must be specified!');
    this.tables = [];
    this.relations = [];
  }

  Model.prototype.addTable = function(canvas, x, y) {
    return this.tables.push(new Table(canvas, "tab_" + this.tables.length, x, y, 100, 60));
  };

  Model.prototype.addRelation = function(canvas, startTabId, endTabId) {
    var endTab, relLen, startTab;
    startTab = this.tables[this.getTabNumberId(startTabId)];
    endTab = this.tables[this.getTabNumberId(endTabId)];
    if (startTab !== void 0 && endTab !== void 0) {
      relLen = this.relations.push(new Relation(canvas, startTab, endTab));
      startTab.addRelation(this.relations[relLen - 1]);
      return endTab.addRelation(this.relations[relLen - 1]);
    } else {
      return false;
    }
  };

  Model.prototype.getTabNumberId = function(fullid) {
    var numberId;
    numberId = fullid.match(/^tab_(\d+)$/);
    if (numberId != null) {
      return Number(numberId[1]);
    } else {
      return false;
    }
  };

  return Model;

})();

if (!(typeof window !== "undefined" && window !== null)) module.exports = Model;

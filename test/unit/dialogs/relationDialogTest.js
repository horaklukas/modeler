goog.require('dm.dialogs.RelationDialog');

global.DB = {
  types: []
};

describe('class RelationDialog', function() {
  var reld;

  reld = null;
  before(function() {
    return reld = dm.dialogs.RelationDialog.getInstance();
  });
  describe('method setIdentifying', function() {
    return it('should save identifying as a boolean value', function() {
      reld.setIdentifying({
        target: {
          value: '0'
        }
      });
      reld.isIdentifying.should.be["false"];
      reld.setIdentifying({
        target: {
          value: '1'
        }
      });
      return reld.isIdentifying.should.be["true"];
    });
  });
  describe('method swapTables', function() {
    var child, ev, gebc, parent;

    ev = {
      preventDefault: sinon.spy(),
      target: null
    };
    gebc = null;
    parent = null;
    child = null;
    before(function() {
      gebc = sinon.stub(goog.dom, 'getElementByClass');
      parent = document.createElement('div');
      child = document.createElement('div');
      gebc.withArgs('parent').returns(parent);
      return gebc.withArgs('child').returns(child);
    });
    beforeEach(function() {
      reld.tablesSwaped = false;
      parent.innerHTML = 'Parent name';
      child.innerHTML = 'Child name';
      ev.preventDefault.reset();
      return gebc.reset();
    });
    after(function() {
      return gebc.restore();
    });
    it('should toggle swapped table flag', function() {
      reld.swapTables(ev);
      return reld.tablesSwaped.should.be["true"];
    });
    return it('should swap content text inside child and parent', function() {
      reld.swapTables(ev);
      parent.textContent.should.equal('Child name');
      return child.textContent.should.equal('Parent name');
    });
  });
  return describe('method show', function() {
    var getChildName, getParentName, isIdent, rel, setval, setvis;

    setvis = null;
    setval = null;
    isIdent = sinon.stub();
    getParentName = sinon.stub();
    getChildName = sinon.stub();
    rel = {
      getModel: function() {
        return {
          isIdentifying: isIdent
        };
      },
      parentTab: {
        getModel: function() {
          return {
            getName: getParentName
          };
        }
      },
      childTab: {
        getModel: function() {
          return {
            getName: getChildName
          };
        }
      }
    };
    before(function() {
      setvis = sinon.stub(reld, 'setVisible');
      return setval = sinon.stub(reld, 'setValues');
    });
    beforeEach(function() {
      isIdent.reset();
      getParentName.reset();
      getChildName.reset();
      setvis.reset();
      return setval.reset();
    });
    after(function() {
      setvis.restore();
      return setval.restore();
    });
    it('should only show/hide if relation object not passed', function() {
      reld.show(true);
      reld.show(false);
      isIdent.should.not.been.called;
      getParentName.should.not.been.called;
      return getChildName.should.not.been.called;
    });
    it('should show dialog if passed true', function() {
      reld.show(true);
      return setvis.should.been.calledWithExactly(true);
    });
    it('should hide dialog if passed false', function() {
      reld.show(false);
      return setvis.should.been.calledWithExactly(false);
    });
    it('should set identifying flag', function() {
      isIdent.returns(true);
      reld.show(true, rel);
      reld.isIdentifying.should.be["true"];
      isIdent.returns(false);
      reld.show(true, rel);
      return reld.isIdentifying.should.be["false"];
    });
    return it('should set values from passed relation to dialog', function() {
      getParentName.returns('table1');
      getChildName.returns('table2');
      isIdent.returns(true);
      reld.show(true, rel);
      return setval.should.been.calledOnce.and.calledWithExactly('table1', 'table2', true);
    });
  });
});

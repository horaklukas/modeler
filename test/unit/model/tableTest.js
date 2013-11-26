goog.require('dm.model.Table');

describe('class Table', function() {
  var spy, tab;

  tab = null;
  spy = sinon.spy();
  before(function() {
    return tab = new dm.model.Table();
  });
  describe('method setName', function() {
    it('should set empty table name if not passed', function() {
      tab.setName();
      return expect(tab).to.have.property('name_', '');
    });
    return it('should save passed name', function() {
      tab.setName('tablename');
      return expect(tab).to.have.property('name_', 'tablename');
    });
  });
  describe('method setColumn', function() {
    beforeEach(function() {
      tab.columns_ = [
        {
          name: 'one',
          type: 'char'
        }, {
          name: 'second',
          type: 'varchar'
        }, {
          name: 'three',
          type: 'number'
        }
      ];
      return spy.reset();
    });
    it('should save column to passed index', function() {
      expect(tab.columns_[1]).to.have.property('name', 'second');
      tab.setColumn({
        name: 'another second',
        type: null
      }, 1);
      return expect(tab.columns_[1]).to.have.property('name', 'another second');
    });
    it('should save column to end if index not passed', function() {
      expect(tab.columns_[3]).to.not.exist;
      tab.setColumn({
        name: 'four',
        type: 'char'
      }, null);
      return expect(tab.columns_[3]).to.exist.and.have.property('name', 'four');
    });
    it('should dispatch `column-change` event if passed column index', function() {
      goog.events.listenOnce(tab, 'column-change', spy);
      tab.setColumn({
        name: 'sixty',
        type: 'sly'
      }, 34);
      spy.should.been.calledOnce;
      spy.lastCall.args[0].should.have.deep.property('column.data').that.deep.equal({
        name: 'sixty',
        type: 'sly'
      });
      return spy.lastCall.args[0].should.have.deep.property('column.index', 34);
    });
    return it('should dispatch `column-add` event if not passed column index', function() {
      goog.events.listenOnce(tab, 'column-add', spy);
      tab.setColumn({
        name: 'seventy',
        type: 'arnie'
      });
      spy.should.been.calledOnce;
      spy.lastCall.args[0].should.have.deep.property('column.data').that.deep.equal({
        name: 'seventy',
        type: 'arnie'
      });
      return spy.lastCall.args[0].should.not.have.deep.property('column.index');
    });
  });
  describe('method removeColumn', function() {
    beforeEach(function() {
      tab.columns_ = [
        {
          name: 'one',
          type: 'char'
        }, {
          name: 'second',
          type: 'varchar'
        }, {
          name: 'three',
          type: 'number'
        }
      ];
      return spy.reset();
    });
    it('should remove column with given index', function() {
      expect(tab.columns_).to.have.property(1).that.deep.equal({
        name: 'second',
        type: 'varchar'
      });
      tab.removeColumn(1);
      tab.columns_.should.have.property('length', 2);
      return expect(tab.columns_).to.have.property(1).that.deep.equal({
        name: 'three',
        type: 'number'
      });
    });
    return it('should dispatch `column-delete` with index of column to delete', function() {
      goog.events.listenOnce(tab, 'column-delete', spy);
      tab.removeColumn(2);
      spy.should.been.calledOnce;
      spy.lastCall.args[0].should.to.have.deep.property('column.index', 2);
      return spy.lastCall.args[0].should.have.deep.property('column.data', null);
    });
  });
  return describe('method getColumnById', function() {
    beforeEach(function() {
      return tab.columns_ = [
        {
          name: 'one',
          type: 'char'
        }, {
          name: 'second',
          type: 'varchar'
        }
      ];
    });
    it('should return null if index not passed', function() {
      return expect(tab.getColumnById()).to.be["null"];
    });
    it('return null if column with passed index not exist', function() {
      return expect(tab.getColumnById(3)).to.be["null"];
    });
    return it('return column with passed index if exists', function() {
      return expect(tab.getColumnById(1)).to.deep.equal({
        name: 'second',
        type: 'varchar'
      });
    });
  });
});

describe('class ColumnsChange', function() {
  return describe('constructor', function() {
    it('should be `column-add` type if passed only column, not index', function() {
      var ev;

      ev = new dm.model.Table.ColumnsChange('column');
      return ev.should.have.property('type', 'column-add');
    });
    it('should be `column-change` type if passed column and index', function() {
      var ev;

      ev = new dm.model.Table.ColumnsChange('column', 3);
      return ev.should.have.property('type', 'column-change');
    });
    return it('should be `column-delete` type if passed only index, not column', function() {
      var ev;

      ev = new dm.model.Table.ColumnsChange(null, 4);
      return ev.should.have.property('type', 'column-delete');
    });
  });
});

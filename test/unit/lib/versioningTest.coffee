mocks = 
  fs: 
    readdir: sinon.stub(), readFile: sinon.stub(), writeFile: sinon.stub()
    stat: sinon.stub()
  mkdirp: sinon.stub()
  crupto: createHash: sinon.stub()

mockery.enable useCleanCache: true

mockery.registerMock 'fs', mocks.fs
mockery.registerMock 'mkdirp', mocks.mkdirp
mockery.registerAllowables ['async', 'path', 'xdiff']

reposDir = require('path').resolve  __dirname, '../../../data/versions'
vers = require '../../../lib/routes/socket/versioning'

describe 'Module versioning', ->
  before ->
    @cb = sinon.spy()

  beforeEach ->
    @cb.reset()
    mocks.mkdirp.reset()

  after ->
    mockery.deregisterAll()
    mockery.disable()

  describe 'method getRepos', ->
    beforeEach ->
      @cb.reset()

    it 'should response with list of repos if reading repos dir success', ->
      mocks.fs.readdir.withArgs(reposDir).yields null, [
        'repo1', 'repo2', 'repo3'
      ]
      vers.getRepos @cb

      @cb.should.been.calledOnce.and.calledWithExactly null, [
        'repo1', 'repo2', 'repo3'
      ]

    it 'should response with error if error occured ant not ENOENT', ->
      mocks.fs.readdir.withArgs(reposDir).yields code: 'EACCESS'
      vers.getRepos @cb

      @cb.should.been.calledOnce.and.calledWithExactly code: 'EACCESS'

    it 'should create repos directory if it not exist yet', ->
      mocks.fs.readdir.withArgs(reposDir).yields code: 'ENOENT'
      mocks.mkdirp.withArgs(reposDir).yields null, '/some path'
      vers.getRepos @cb

      @cb.should.been.calledOnce.and.calledWithExactly null, []
      mocks.mkdirp.should.been.calledOnce.and.calledWith reposDir

    it 'should response with error if creating reposDir failed', ->
      mocks.fs.readdir.withArgs(reposDir).yields code: 'ENOENT'
      mocks.mkdirp.withArgs(reposDir).yields 'Error at creating'
      vers.getRepos @cb
      
      @cb.should.been.calledOnce.and.calledWithExactly 'Error at creating'
      mocks.mkdirp.should.been.calledOnce.and.calledWith reposDir

  describe 'method readRepo', ->
    beforeEach ->
      @cb.reset()
      mocks.fs.readdir.reset()

    it 'should response with error if reading repo give error', ->
      vers.readRepo 'repo1', @cb
      mocks.fs.readdir.withArgs(reposDir+'/repo1').yield 'Repo doesnt exist'

      @cb.should.been.calledOnce.and.calledWithExactly 'Repo doesnt exist'

    it 'should return sorted versions of repo', ->
      vers.readRepo 'repo2', @cb
      mocks.fs.readdir.withArgs(reposDir+'/repo2').yield null, [
        '165', '38', '1', '145'
      ]
      mocks.fs.readFile.withArgs(reposDir+'/repo2/1').yield null, '{}'
      mocks.fs.readFile.withArgs(reposDir+'/repo2/38').yield null, '{}'
      mocks.fs.readFile.withArgs(reposDir+'/repo2/145').yield null, '{}'
      mocks.fs.readFile.withArgs(reposDir+'/repo2/165').yield null, '{}'

      @cb.should.been.calledOnce 
      {args} = @cb.lastCall
      expect(args[0]).to.not.exist
      expect(args[1]).to.be.an 'array'
      expect(args[1][0]).to.have.property 'date', '1'
      expect(args[1][1]).to.have.property 'date', '38'
      expect(args[1][2]).to.have.property 'date', '145'
      expect(args[1][3]).to.have.property 'date', '165'

    it 'should response with error if reading any file failed', (done) ->
      mocks.fs.readdir.withArgs(reposDir+'/repo2').yields null, ['16']
      mocks.fs.readFile.withArgs(reposDir+'/repo2/16').yields 'fuck error'

      vers.readRepo 'repo2', (err) ->
        expect(err).to.equal 'fuck error'
        done() 

    it 'should read description of each version', (done) ->
      mocks.fs.readdir.withArgs(reposDir+'/repo4').yields null, ['9','16']
      mocks.fs.readFile.withArgs(reposDir+'/repo4/16').yields(
        null, '{"descr":"vers 16"}'
      )
      mocks.fs.readFile.withArgs(reposDir+'/repo4/9').yields(
        null, '{"descr":"vers 9"}'
      )

      vers.readRepo 'repo4', (err, data) ->
        expect(err).to.not.exist
        expect(data).to.be.an 'array'
        expect(data[0]).to.have.property 'descr', 'vers 9'
        expect(data[1]).to.have.property 'descr', 'vers 16'
        done()

  describe 'method addVersion', ->
    before ->
      sinon.stub vers, 'readRepo'
      sinon.stub(Date::, 'getTime').returns 12345

    beforeEach ->
      @cb.reset()
      vers.readRepo.reset()
      mocks.mkdirp.reset()
      mocks.fs.writeFile.reset()

    after ->
      vers.readRepo.restore()
      Date::getTime.restore()

    it 'should response error if making repo dir failed', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo3').yields 'Permission denied'

      vers.addVersion 'repo3', 'data', (err) ->
        expect(err).to.equal 'Permission denied'
        done()

    it 'should response error if reading repo failed', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo4').yields null, '/path'
      vers.readRepo.withArgs('repo4').yields 'Cannot read'

      vers.addVersion 'repo4', 'data', (err) ->
        expect(err).to.equal 'Cannot read'
        done()

    it 'should write whole data if no previous versions are available', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo5').yields null, '/path'
      vers.readRepo.withArgs('repo5').yields null, []
      mocks.fs.writeFile.yields null

      vers.addVersion 'repo5', {model:'content',descr: 'bla'}, (err) ->
        expect(err).to.not.exist
        mocks.fs.writeFile.should.been.calledOnce.and.calledWith(
          reposDir+'/repo5/12345'
        )
        expect(mocks.fs.writeFile.lastCall.args[1]).to.equal(
          '{"model":"content","descr":"bla"}'
        )
        done()

    it 'should response with error if content is broken', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo6').yields null, 'path'
      vers.readRepo.withArgs('repo6').yields null, []

      vers.addVersion 'repo6', undefined, (err) ->
        expect(err).to.match /^Wrong version data/
        done()

    it 'should response with error if first repo version read failed', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo7').yields null, '/path'
      vers.readRepo.withArgs('repo7').yields null, [
        {date:'12'}, {date:'34'}, {date:'87'}
      ]
      mocks.fs.readFile.withArgs(reposDir+'/repo7/12').yields 'Read vers failed'

      vers.addVersion 'repo7', {}, (err) ->
        expect(err).to.equal 'Read vers failed'
        done()

    it 'should response with error if first repo version read failed', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo7').yields null, '/path'
      vers.readRepo.withArgs('repo7').yields null, [
        {date:'12'}, {date:'34'}, {date:'87'}
      ]
      mocks.fs.readFile.withArgs(reposDir+'/repo7/12').yields 'Read vers failed'

      vers.addVersion 'repo7', {}, (err) ->
        expect(err).to.equal 'Read vers failed'
        done()

    it 'should write data diff to first version if previous versions exist', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo8').yields null, '/path'
      vers.readRepo.withArgs('repo8').yields null, [
        {date:'12'}, {date:'34'}
      ]
      mocks.fs.readFile.withArgs(reposDir+'/repo8/12').yields(
        null, '{"model": {"version": "original content"}, "descr":"bla"}'
      )
      mocks.fs.writeFile.yields null

      data = model: {version: 'edited content'}, descr: 'foo'
      vers.addVersion 'repo8', data , (err) ->
        expect(err).to.not.exist
        mocks.fs.writeFile.should.been.calledOnce.and.calledWith(
          reposDir+'/repo8/12345'
          '{"model":[["set",["root","version"],"edited content"]],"descr":"foo"}'
        )
        done()

  describe 'method getVersion', ->
    before ->
      sinon.stub vers, 'readRepo'

    beforeEach ->
      @cb.reset()
      vers.readRepo.reset()
      mocks.fs.readFile.reset()

    after ->
      vers.readRepo.restore()

    it 'should response with error if reading repo fail', ->
      vers.getVersion 'repo1', '12345', @cb
      vers.readRepo.withArgs('repo1').yield 'Repo read fail'

      @cb.should.been.calledOnce.and.calledWithExactly 'Repo read fail'
      mocks.fs.readFile.should.not.been.called

    it 'should response with error if repository havent any version', ->
      vers.getVersion 'repo2', '12345', @cb
      vers.readRepo.withArgs('repo2').yield null, []

      @cb.should.been.calledOnce.and.calledWithExactly 'Repo doesnt contain any version'
      mocks.fs.readFile.should.not.been.called

    it 'should read whole content if only one version exist', ->
      vers.getVersion 'repo3', '12345', @cb
      vers.readRepo.withArgs('repo3').yield null, [{date:'12345'}]
      mocks.fs.readFile.withArgs(reposDir+'/repo3/12345').yield(
        null, '{"alone":"vers"}'
      )

      @cb.should.been.calledOnce.and.calledWithExactly null, {'alone': 'vers'}
      mocks.fs.readFile.should.been.calledOnce

    it 'should response with error if the only one version has different name', ->
      vers.getVersion 'repo4', '12345', @cb
      vers.readRepo.withArgs('repo4').yield null, [{date:'654321'}]

      @cb.should.been.calledOnce.and.calledWithExactly(
        'Versions doesnt match: 12345-654321'
      )
      mocks.fs.readFile.should.not.been.called

    it 'should response with error if reading original version fail', ->
      vers.getVersion 'repo5', '12345', @cb
      vers.readRepo.withArgs('repo5').yield null, [{date: '123'}, {date:'456'}]
      mocks.fs.readFile.withArgs(reposDir+'/repo5/123').yield 'File not exist'

      @cb.should.been.calledOnce.and.calledWithExactly 'File not exist'
      mocks.fs.readFile.should.been.calledOnce

    it 'should response with error if reading required version patch fail', ->
      vers.getVersion 'repo6', '1234', @cb
      vers.readRepo.withArgs('repo6').yield null, [{date:'12'}, {date:'3456'}]
      mocks.fs.readFile.withArgs(reposDir+'/repo6/12').yield null, '{}'
      mocks.fs.readFile.withArgs(reposDir+'/repo6/1234').yield 'File isnt readable'

      @cb.should.been.calledOnce.and.calledWithExactly 'File isnt readable'
      mocks.fs.readFile.should.been.calledTwice

    it 'should reaad patched original, which is required object version', ->
      vers.getVersion 'repo7', '54321', @cb
      vers.readRepo.withArgs('repo7').yield null, [{date:'54'}, {date:'54321'}]
      mocks.fs.readFile.withArgs(reposDir+'/repo7/54').yield(
        null, '{"model":{"version":"original content"},"descr": "bla"}'
      )
      mocks.fs.readFile.withArgs(reposDir+'/repo7/54321').yield(
        null,'{"model":[["set",["root","version"],"edited content"]],"descr":"foo"}'
      )

      @cb.should.been.calledOnce.and.calledWith null
      expect(@cb.lastCall.args[1]).to.eql(
        {model: {version: 'edited content'}, descr: 'foo'}
      )
      mocks.fs.readFile.should.been.calledTwice

    it 'should read whole version if required version is first', ->
      vers.getVersion 'repo8', '54', @cb
      vers.readRepo.withArgs('repo8').yield null, [{date:'54'}, {date:'54321'}]
      mocks.fs.readFile.withArgs(reposDir+'/repo8/54').yield(
        null, '{"model":{"version":"original content"},"descr": "bla"}'
      )

      @cb.should.been.calledOnce.and.calledWith null
      expect(@cb.lastCall.args[1]).to.eql(
        {model: {version: 'original content'}, descr: 'bla'}
      )
      mocks.fs.readFile.should.been.calledOnce

  describe.skip 'method readVersionFile', ->
    beforeEach ->
      @cb.reset()

    it 'should reponse error if reading version file fail', ->
      vers.readVersionFile 'repo1', '12345', @cb
      mocks.fs.readFile.withArgs(reposDir+'/repo1/12345').yield 'No such file'

      @cb.should.been.calledOnce.and.calledWithExactly 'No such file'

    it 'should reponse error if version content isnt valid JSON', ->
      vers.readVersionFile 'repo2', '1234', @cb
      mocks.fs.readFile.withArgs(reposDir+'/repo2/1234').yield null, '{bla}'

      @cb.should.been.calledOnce
      @cb.lastCall.args[0].should.match /^SyntaxError/

    it 'should reponse parsed content if everything is ok', ->
      vers.readVersionFile 'repo3', '123', @cb
      mocks.fs.readFile.withArgs(reposDir+'/repo3/123').yield(
        null, '{"vers": "content"}'
      )

      @cb.should.been.calledOnce.and.calledWithExactly null, {'vers':'content'}

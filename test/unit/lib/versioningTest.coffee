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
vers = require '../../../lib/versioning'

describe 'Module versioning', ->
  before ->
    @cb = sinon.spy()

  after ->
    mockery.deregisterAll()
    mockery.disable()

  describe.skip 'method getRepos', ->
    beforeEach ->
      @cb.reset()

    it 'should response with list of repos if reading repos dir success', ->
      vers.getRepos @cb
      mocks.fs.readdir.withArgs(reposDir).yield null, [
        'repo1', 'repo2', 'repo3'
      ]

      @cb.should.been.calledOnce.and.calledWithExactly null, [
        'repo1', 'repo2', 'repo3'
      ]

    it 'should response with error if reading repos dir failed', ->
      vers.getRepos @cb
      mocks.fs.readdir.withArgs(reposDir).yield 'Dir isnt readable'

      @cb.should.been.calledOnce.and.calledWithExactly 'Dir isnt readable'


  describe 'method readRepo', ->
    beforeEach ->
      @cb.reset()

    it 'should response with error if reading repo give error', ->
      vers.readRepo 'repo1', @cb
      mocks.fs.readdir.withArgs(reposDir+'/repo1').yield 'Repo doesnt exist'

      @cb.should.been.calledOnce.and.calledWithExactly 'Repo doesnt exist'

    it 'should return sorted versions of repo', ->
      vers.readRepo 'repo2', @cb
      mocks.fs.readdir.withArgs(reposDir+'/repo2').yield null, [
        '165', '38', '321', '294', '1', '145'
      ]

      @cb.should.been.calledOnce.and.calledWithExactly null, [
        '1', '38', '145', '165', '294', '321' 
      ]

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
      mocks.mkdirp.withArgs(reposDir+'/repo4').yields null
      vers.readRepo.withArgs('repo4').yields 'Cannot read'

      vers.addVersion 'repo4', 'data', (err) ->
        expect(err).to.equal 'Cannot read'
        done()

    it 'should write whole data if no previous versions are available', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo5').yields null
      vers.readRepo.withArgs('repo5').yields null, []
      mocks.fs.writeFile.yields null

      vers.addVersion 'repo5', {version: 'content'}, (err) ->
        expect(err).to.not.exist
        mocks.fs.writeFile.should.been.calledOnce.and.calledWith(
          reposDir+'/repo5/12345'
          '{"version":"content"}'
        )
        done()

    it 'should response with error if content is broken', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo6').yields null
      vers.readRepo.withArgs('repo6').yields null, []

      vers.addVersion 'repo6', undefined, (err) ->
        expect(err).to.match /^Wrong version data/
        done()

    it 'should response with error if first repo version read failed', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo7').yields null
      vers.readRepo.withArgs('repo7').yields null, ['12', '34', '87']
      mocks.fs.readFile.withArgs(reposDir+'/repo7/12').yields 'Read vers failed'

      vers.addVersion 'repo7', {}, (err) ->
        expect(err).to.equal 'Read vers failed'
        done()

    it 'should response with error if first repo version read failed', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo7').yields null
      vers.readRepo.withArgs('repo7').yields null, ['12', '34', '87']
      mocks.fs.readFile.withArgs(reposDir+'/repo7/12').yields 'Read vers failed'

      vers.addVersion 'repo7', {}, (err) ->
        expect(err).to.equal 'Read vers failed'
        done()

    it 'should write data diff to first version if previous versions exist', (done) ->
      mocks.mkdirp.withArgs(reposDir+'/repo8').yields null
      vers.readRepo.withArgs('repo8').yields null, ['12', '34']
      mocks.fs.readFile.withArgs(reposDir+'/repo8/12').yields(
        null, '{"version": "original content"}'
      )
      mocks.fs.writeFile.yields null

      vers.addVersion 'repo8', {version: 'edited content'}, (err) ->
        console.log(err)
        expect(err).to.not.exist
        mocks.fs.writeFile.should.been.calledOnce.and.calledWith(
          reposDir+'/repo8/12345'
          '[["set",["root","version"],"edited content"]]'
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
      vers.readRepo.withArgs('repo3').yield null, ['12345']
      mocks.fs.readFile.withArgs(reposDir+'/repo3/12345').yield(
        null, '{"alone":"vers"}'
      )

      @cb.should.been.calledOnce.and.calledWithExactly null, {'alone': 'vers'}
      mocks.fs.readFile.should.been.calledOnce

    it 'should response with error if the only one version has different name', ->
      vers.getVersion 'repo4', '12345', @cb
      vers.readRepo.withArgs('repo4').yield null, ['654321']

      @cb.should.been.calledOnce.and.calledWithExactly(
        'Versions doesnt match: 12345-654321'
      )
      mocks.fs.readFile.should.not.been.called

    it 'should response with error if reading original version fail', ->
      vers.getVersion 'repo5', '12345', @cb
      vers.readRepo.withArgs('repo5').yield null, ['123', '456']
      mocks.fs.readFile.withArgs(reposDir+'/repo5/123').yield 'File not exist'

      @cb.should.been.calledOnce.and.calledWithExactly 'File not exist'
      mocks.fs.readFile.should.been.calledOnce

    it 'should response with error if reading required version patch fail', ->
      vers.getVersion 'repo6', '1234', @cb
      vers.readRepo.withArgs('repo6').yield null, ['12', '3456']
      mocks.fs.readFile.withArgs(reposDir+'/repo6/12').yield null, '{}'
      mocks.fs.readFile.withArgs(reposDir+'/repo6/1234').yield 'File isnt readable'

      @cb.should.been.calledOnce.and.calledWithExactly 'File isnt readable'
      mocks.fs.readFile.should.been.calledTwice

    it 'should write patched original, which is required object version', ->
      vers.getVersion 'repo7', '54321', @cb
      vers.readRepo.withArgs('repo7').yield null, ['54', '321']
      mocks.fs.readFile.withArgs(reposDir+'/repo7/54').yield(
        null, '{"version": "original content"}'
      )
      mocks.fs.readFile.withArgs(reposDir+'/repo7/54321').yield(
        null, '[["set",["root","version"],"edited content"]]'
      )

      @cb.should.been.calledOnce.and.calledWithExactly(
        null, {version: 'edited content'}
      )
      mocks.fs.readFile.should.been.calledTwice

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

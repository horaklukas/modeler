describe 'app socket routes', ->		
	describe.skip 'route getConnections', ->
		before ->
			@cb = sinon.spy()

		beforeEach ->
			mocks.fs.readFile.reset()
			@cb.reset()

		it 'should response with err if reading connections file failed', ->


			@cb.should.been.calledWithExactly 'Error at reading connections file: err'

		it 'should response with err if parsing connections file failed', ->

			@cb.should.been.calledWithExactly 'Error at parsing connections file: err'

		it 'should response with parsed connections if file is ok', ->
			@cb.should.been.calledWithExactly null, {'c1': {'host': 'h1', 'port': 3}}


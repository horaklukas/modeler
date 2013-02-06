Anchor = require '../src/components/objects/anchor'

describe 'class Anchor', ->
	canvas = {}
	describe 'method constructor', ->
		
		before ->
			canvas.rect = sinon.spy()	
		beforeEach ->
			canvas.rect.reset()

		it 'should call method for creating rectangle', ->
			a = new Anchor canvas, 'l', {x:20, y:20}, {x:100, y:100}
			canvas.rect.should.been.calledOnce	 

		it 'should count correct positions for left anchor', ->
			a = new Anchor canvas, 'l', {x:30, y:60}, {x:90, y:160}
			canvas.rect.should.been.calledWithExactly 10, 90

		it 'should count correct positions for right anchor', ->			
			a = new Anchor canvas, 'r', {x:30, y:60}, {x:90, y:160}
			canvas.rect.should.been.calledWithExactly 90, 90

		it 'should count correct positions for top anchor', ->
			a = new Anchor canvas, 't', {x:30, y:60}, {x:90, y:160}
			canvas.rect.should.been.calledWithExactly 40, 40

		it 'should count correct positions for bottom anchor', ->
			a = new Anchor canvas, 'b', {x:30, y:60}, {x:90, y:160}
			canvas.rect.should.been.calledWithExactly 40, 160
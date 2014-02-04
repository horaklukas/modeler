###
Relation = require "#{scriptsDir}/components/model/relation"
rel = null
# Fake canvas that returns obj with spy at attr method
canvas = path: sinon.stub().returns { attr: sinon.spy() }

stab = getConnPoints: sinon.spy()
etab = getConnPoints: sinon.spy()

describe 'class Relation', ->
	describe 'constructor', ->

	describe 'method recountPosition', ->
		gcp = null
		before ->
			fakeEndPoints = 
				start: x: 20, y: 40
				break1: x: 120, y: 100
				break2: x: 120, y: 100
				stop: x: 220, y: 160

			gcp = sinon.stub(Relation::, 'getRelationPoints').returns fakeEndPoints
			rel = new Relation canvas, stab, etab

		beforeEach ->
			gcp.reset()

		after ->
			gcp.restore()

		it 'should count correct path from got end points coordinates', ->
			rel.obj.attr.reset()
			rel.recountPosition()

			rel.obj.attr.should.be.calledOnce
			rel.obj.attr.should.be.calledWithExactly 'path','M20,40L120,100L120,100L220,160'

	describe 'method getPathDistance', ->
		it 'should return false if points are opossite', ->
			less = x:20, y:30
			more = x:70, y:80

			expect(rel.getPathDistance 'left', less, 'right', more).to.be.false
			expect(rel.getPathDistance 'right', more, 'left', less).to.be.false
			expect(rel.getPathDistance 'top', less, 'bottom', more).to.be.false
			expect(rel.getPathDistance 'bottom', more, 'top', less).to.be.false

		it 'should return distance if points arent at same position', ->
			c = x: 0, y:0

			expect(rel.getPathDistance 'left', c, 'left', c).to.be.a 'number'
			expect(rel.getPathDistance 'right', c, 'right', c).to.be.a 'number'
			expect(rel.getPathDistance 'top', c, 'top', c).to.be.a 'number'
			expect(rel.getPathDistance 'bottom', c, 'bottom', c).to.be.a 'number'

	describe 'method getBreakPoints', ->
		it 'should return array with two breaks at indexes 0 and 1', ->
			br = rel.getBreakPoints {x:20, y:30}, 'left', {x:20, y:30}, 'top'

			expect(br).to.be.an('array').and.have.length 2

		it 'should set x and y coordinates for both breaks', ->
			br = rel.getBreakPoints {x:20, y:30}, 'left', {x:20, y:30}, 'top'

			expect(br[0]).to.be.an('object')
									 .to.have.property('x').and.that.is.a 'number'
			expect(br[0]).to.have.property('y').and.that.is.a 'number'

			expect(br[1]).to.be.an('object')
									 .to.have.property('x').and.that.is.a 'number'
			expect(br[1]).to.have.property('y').and.that.is.a 'number'

		it 'should break at y coordinate if positions are left and right', ->
			br = rel.getBreakPoints {x:20, y:30}, 'left', {x:90, y:60}, 'right'

			expect(br[0]).to.deep.equal x: 55, y: 30
			expect(br[1]).to.deep.equal x: 55, y: 60

		it 'should break at x coordinate if positions are top and bottom', ->
			br = rel.getBreakPoints {x:60, y:30}, 'top', {x:120, y:70}, 'bottom'

			expect(br[0]).to.deep.equal x: 60, y: 50
			expect(br[1]).to.deep.equal x: 120, y: 50

		it 'should break at x and y if positions arent at direction', ->
			expect(rel.getBreakPoints {x:20, y:130}, 'top', {x:90, y:100}, 'left')
			.to.deep.equal [{x: 90, y: 130}, {x: 90, y: 130}]		
###
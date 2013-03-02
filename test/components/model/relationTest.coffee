Relation = require "#{srcDir}/components/model/relation"
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
				start: x: 23, y: 45
				stop: x: 234, y: 156

			gcp = sinon.stub(Relation::, 'getEndPointsCoords').returns fakeEndPoints
			rel = new Relation canvas, stab, etab

		beforeEach ->
			gcp.reset()

		after ->
			gcp.restore()

		it 'should count correct path from got end points coordinates', ->
			rel.obj.attr.reset()
			rel.recountPosition()

			rel.obj.attr.should.be.calledOnce
			rel.obj.attr.should.be.calledWithExactly 'path','M23,45L234,156'
		
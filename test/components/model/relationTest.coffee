Relation = require "#{scriptsDir}/components/model/relation"
rel = null
canvas = path: sinon.spy()
stab = getConnPoints: sinon.spy()
etab = getConnPoints: sinon.spy()

describe 'class Relation', ->
	describe 'constructor', ->

	describe 'method recountPosition', ->
		###gcp = null
		before ->
			rel = new Relation canvas, stab, etab
			rel.obj = attr: sinon.spy()
			gcp = sinon.stub(rel, 'getEndPointsCoords').returns start: x: 23, y: 45, stop: x: 234, y: 156

		it 'should count correct path from got end points coordinates', ->
			Relation.recountPosition()

			rel.obj.attr.should.be.calledOnce
			rel.obj.attr.should.be.calledWithExactly 'M23,45L234,156'
		###
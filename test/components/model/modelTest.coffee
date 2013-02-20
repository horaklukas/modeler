Model = require "#{srcDir}/components/model/model"
model = null
canvas = $('canvas')

describe 'class Model', ->
	model = new Model()

	describe 'constructor', ->
		it 'should create empty lists of tables and relations', ->
			model.tables.should.be.an('array').and.empty
			model.relations.should.be.an('array').and.empty
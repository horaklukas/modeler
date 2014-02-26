goog.require 'dm.sqlgen.Sql92'

describe 'class SQL92 generator', ->
	gen = null

	before ->
		gen = new dm.sqlgen.Sql92()

	describe 'method getUniqueConstraintName', ->
		beforeEach ->
			gen.relConstraintNames = []

		it 'should add index 0 at the end of name if its first name occurence', ->
			constrName = 'constr_chi_par_fk0'

			expect(gen.getUniqueConstraintName 'child', 'parent').to.equal constrName

		it 'should add next index by constraint name occurences', ->
			gen.relConstraintNames = 	['constr_chi_par_fk0', 'constr_chi_par_fk1']
			constrName = 'constr_chi_par_fk2'

			expect(gen.getUniqueConstraintName 'child', 'parent').to.equal constrName
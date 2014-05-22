postgres7 = require '../../../lib/defs/postgresql-7'
postgres8 = require '../../../lib/defs/postgresql-8'
postgres9 = require '../../../lib/defs/postgresql-9'

describe 'definitions', ->
  describe 'postgres 7', ->
    it 'should define four definitions', ->
      expect(postgres7).to.be.an 'array'
      expect(postgres7).to.have.length 4

    describe '7-1', ->
      it 'should define it', ->
        expect(postgres7[0]).to.have.property 'version', '7.1'
        expect(postgres7[0]).to.have.property 'types'
        expect(postgres7[0].types).to.have.property 'numeric'
        expect(postgres7[0].types).to.have.property 'monetary'
        expect(postgres7[0].types).to.have.property 'string'
        expect(postgres7[0].types).to.have.property 'datetime'
        expect(postgres7[0].types).to.have.property 'boolean'
        expect(postgres7[0].types).to.have.property 'geometric'
        expect(postgres7[0].types).to.have.property 'network address'
        expect(postgres7[0].types).to.have.property 'bit'
        expect(postgres7[0].types).to.have.property 'special'

      it 'should not contain bigserial numeric type', ->
        expect(postgres7[0].types.numeric).to.not.contain 'bigserial'

    describe '7-2', ->
      it 'should define it', ->
        expect(postgres7[1]).to.have.property 'version', '7.2'

      it 'should add bigserial', ->
        expect(postgres7[1].types.numeric).to.contain 'bigserial'

      it 'should have category special as a last definition', ->
        expect(postgres7[1].types).to.have.property 'special'

    describe '7-3', ->
      it 'should define it', ->
        expect(postgres7[2]).to.have.property 'version', '7.3'

      it 'should delete category special', ->
        expect(postgres7[2].types).to.not.have.property 'special'

    describe '7-4', ->
      it 'should define it', ->
        expect(postgres7[3]).to.have.property 'version', '7.4'

      it 'should have same types as a 7-3', ->
        expect(postgres7[3].types).to.deep.equal postgres7[2].types

  describe 'postgres 8', ->
    it 'should define fifth definitions', ->
      expect(postgres8).to.be.an 'array'
      expect(postgres8).to.have.length 5

    describe '8-0', ->
      it 'should define it', ->
        expect(postgres8[0]).to.have.property 'version', '8.0'

      it 'should equal to last postgres 7 version', ->
        expect(postgres8[0].types).to.deep.equal(
          postgres7[postgres7.length - 1].types
        )

    describe '8-1', ->
      it 'should define it', ->
        expect(postgres8[1]).to.have.property 'version', '8.1'

      it 'should equal to 8-0 version', ->
        expect(postgres8[1].types).to.deep.equal postgres8[0].types

    describe '8-2', ->
      it 'should define it', ->
        expect(postgres8[2]).to.have.property 'version', '8.2'

      it 'should equal to 8-1 version', ->
        expect(postgres8[2].types).to.deep.equal postgres8[1].types

      it 'should not have categories `text search` and `special`', ->
        expect(postgres8[2]).to.not.have.property 'text search'
        expect(postgres8[2]).to.not.have.property 'special'

    describe '8-3', ->
      it 'should define it', ->
        expect(postgres8[3]).to.have.property 'version', '8.3'

      it 'should define new category `text search`', ->
        expect(postgres8[3].types).to.have.property 'text search'

      it 'should define new category `special`', ->
        expect(postgres8[3].types).to.have.property 'special'

    describe '8-4', ->
      it 'should define it', ->
        expect(postgres8[4]).to.have.property 'version', '8.4'

      it 'should equal to 8-3 version', ->
        expect(postgres8[4].types).to.deep.equal postgres8[3].types

  describe 'postgres 9', ->
    it 'should define fourth definitions', ->
      expect(postgres9).to.be.an 'array'
      expect(postgres9).to.have.length 4

    describe '9-0', ->
      it 'should define it', ->
        expect(postgres9[0]).to.have.property 'version', '9.0'

      it 'should equal to last postgres 8 version', ->
        expect(postgres9[0].types).to.deep.equal(
          postgres8[postgres8.length - 1].types
        )

    describe '9-1', ->
      it 'should define it', ->
        expect(postgres9[1]).to.have.property 'version', '9.1'

      it 'should equal to 9-0 version', ->
        expect(postgres9[1].types).to.deep.equal postgres9[0].types

    describe '9-2', ->
      it 'should define it', ->
        expect(postgres9[2]).to.have.property 'version', '9.2'
        
      it 'should add new type `smallserial` to category `numeric`', ->
        expect(postgres9[2].types.numeric).to.contain 'smallserial'

      it 'should add new type `json` to category `special`', ->
        expect(postgres9[2].types.special).to.contain 'json'

    describe '9-3', ->
      it 'should define it', ->
        expect(postgres9[3]).to.have.property 'version', '9.3'

      it 'should equal to 9-2 version', ->
        expect(postgres9[3].types).to.deep.equal postgres9[2].types

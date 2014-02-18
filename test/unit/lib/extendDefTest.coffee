extend = require '../../../lib/extendDef'

describe 'Module extendDef', ->
	target = 
		name: 'target'
		props: ['target_one', 'target_two']

	object1 = 
		name: 'object'
		props: [ 'object_one'	]

	it 'should rewrite simple types like string, boolean or number', ->
		obj1 = name: 'object1', version: 1, base: true
		obj2 = name: 'object2', version: 2, base: false

		extend obj1, obj2

		expect(obj1).to.deep.equal name: 'object2', version: 2, base: false


	it 'should add properties from second def that first not contains', ->
		obj1 = name: 'object'
		obj2 = secondName: 'objectovic', version: 3

		extend obj1, obj2

		expect(obj1).to.deep.equal {
			name: 'object', secondName: 'objectovic', version: 3
		}

	it 'should extend also deep properties', ->
		obj1 =
			name: 'object'
			types:
				group1: 'group1' 
				group2: 'group2'

		obj2 =
			name: 'object2'
			types:
				group3: 'group3' 
				group4: 'group4' 

		extend obj1, obj2

		expect(obj1).to.deep.equal name: 'object2', types: {
			group1: 'group1', group2: 'group2', group3: 'group3', group4: 'group4'
		}

	it 'should concat arrays', ->
		obj1 =
			types:
				group1: ['type1obj1', 'type2obj1', 'type3obj1']

		obj2 =
			types:
				group1: ['type1obj2', 'type2obj2'] 

		extend obj1, obj2

		expect(obj1).to.have.deep.property 'types.group1'
		expect(obj1.types.group1).to.deep.equal [
			'type1obj1', 'type2obj1', 'type3obj1', 'type1obj2', 'type2obj2'
		]

	it 'should filter duplicated values of two arrays', ->
		obj1 =
			types:
				group1: ['type1obj1', 'type2obj1', 'samevalue', ]

		obj2 =
			types:
				group1: ['type1obj2', 'samevalue', 'type2obj2'] 

		extend obj1, obj2

		expect(obj1).to.have.deep.property 'types.group1'
		expect(obj1.types.group1).to.deep.equal [
			'type1obj1', 'type2obj1', 'samevalue', 'type1obj2', 'type2obj2'
		]

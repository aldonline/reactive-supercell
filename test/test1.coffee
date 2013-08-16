chai = require 'chai'
should = chai.should()
reactivity = require 'reactivity'

cell = require '../lib/supercell'

# TODO: we should use the same suite as cell
describe 'a default supercell behaves like a regular cell', ->
  c1 = cell()
  it 'should initially have an undefined value', -> should.not.exist c1()
  it 'should not have a defined type', -> should.not.exist c1.type()
  it 'should be nullable', -> c1.nullable().should.equal true
  it 'should accept a string value', -> c1 'foo'  
  it 'should return this string value', -> c1().should.equal 'foo'
  it 'should accept a boolean value too', -> c1 true
  it 'and return it', -> c1().should.equal true
  it 'setting any value always returns undefined', ->
    should.not.exist c1 'a'
    should.not.exist c1 1
    should.not.exist c1 true

describe 'a typed cell', ->
  c = cell init: 'hello'
  it 'should be initalized to a value', -> c().should.equal 'hello'
  
  it 'should be of type string', -> c.type().should.equal 'string'
  it 'should be non-nullable', -> c.nullable().should.equal no
  
  it 'should accept a string value', -> c 'foo'  
  it 'should return this string value', -> c().should.equal 'foo'
  
  it 'should accept a boolean value too', -> c true
  it 'but throw an error when querying', -> c.should.throw()
  
  it 'should accept a new string value', -> c 'bar'  
  it 'should return this string value', -> c().should.equal 'bar'

  it 'should accept a null value', -> c null
  it 'but throw an error when querying', -> c.should.throw()


describe 'a supercell', ->
  it 'should be reactive', ->
    c = cell()
    values = []
    reactivity c, (e, r) -> values.push [e, r]
    values.should.have.length 1
    should.not.exist values[0][0]
    should.not.exist values[0][1]
    
    c 'a'
    values.should.have.length 2
    should.not.exist values[1][0]
    should.exist v = values[1][1]
    v.should.equal 'a'

    c null
    values.should.have.length 3
    should.not.exist values[2][0]
    should.not.exist values[2][1]


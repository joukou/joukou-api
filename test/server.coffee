assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()
chai.use( require( 'chai-http' ) )

describe 'server', ->
  it 'is true', ->
    true.should.be.true

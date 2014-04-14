assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()
chai.use( require( 'chai-http' ) )

server = require( '../dist/server' )

describe 'server', ->
  it 'is true', ->
    true.should.be.true

  after ( done ) ->
    server.once( 'close', done )
    server.close()
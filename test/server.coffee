assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()
chai.use( require( 'chai-http' ) )

server = require( '../dist/server' )

describe 'server', ->
  
  it 'is true', ->
    true.should.be.true

  describe 'Cross Origin Resource Sharing', ->

    specify 'sends the expected CORS response headers', ->
      chai.request( server )
        .get( '/' )
        .req( ( req ) ->
          req.set( 'origin', 'https://joukou.com' )
        )
        .res( ( res ) ->
          res.should.have.status(200)
          res.should.have.header( 'access-control-allow-origin' )
          res.should.have.header( 'access-control-allow-credentials', 'true' )
          res.should.have.header( 'access-control-expose-headers' )
        )

  after ( done ) ->
    server.once( 'close', done )
    server.close()
assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()
chai.use( require( 'chai-http' ) )

server = require( '../dist/server' )

describe 'server', ->
  
  it 'true is true', ->
    true.should.be.true

  describe 'Cross Origin Resource Sharing', ->

    specify 'sends the expected CORS response headers', ->
      chai.request( server )
        .get( '/' )
        .req( ( req ) ->
          req.set( 'origin', 'https://joukou.com' )
        )
        .res( ( res ) ->
          res.should.have.status( 200 )
          res.should.have.header( 'access-control-allow-origin', 'https://joukou.com' )
          res.should.have.header( 'access-control-expose-headers' )
        )

    specify 'responds to a CORS preflight request', ->
      chai.request( server )
        .options( '/' )
        .req( ( req ) ->
          req.set( 'origin', 'https://joukou.com' )
          req.set( 'access-control-request-method', 'PUT' )
          #res.set( 'access-control-request-headers', 'x-custom-header' )
        )
        .res( ( res ) ->
          res.should.have.status( 204 )
          res.should.have.header( 'access-control-allow-origin', 'https://joukou.com' )
          res.should.have.header( 'access-control-allow-credentials', 'true' )
          res.should.have.header( 'access-control-allow-methods', 'PUT, OPTIONS' )
          res.should.have.header( 'access-control-allow-headers', 'accept, accept-version, content-type, request-id, origin, x-api-version, x-request-id, x-requested-with, authorization, accept, accept-version, content-type, request-id, origin, x-api-version, x-request-id' )
        )



  #after ( done ) ->
  #  server.once( 'close', done )
  #  server.close()
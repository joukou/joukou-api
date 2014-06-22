assert = require( 'assert' )
chai   = require( 'chai' )
should = chai.should()
chai.use( require( 'chai-http' ) )

server = require( '../dist/server' )

describe 'server', ->

  describe 'Cross Origin Resource Sharing', ->

    specify 'sends the expected CORS response headers', ( done ) ->
      chai.request( server )
        .get( '/' )
        .req( ( req ) ->
          req.set( 'origin', 'https://joukou.com' )
        )
        .res( ( res ) ->
          res.should.have.status( 200 )
          res.should.have.header( 'access-control-allow-origin', 'https://joukou.com' )
          res.should.have.header( 'access-control-expose-headers' )
          done()
        )

    specify 'responds to a CORS preflight request', ( done ) ->
      chai.request( server )
        .options( '/persona' )
        .req( ( req ) ->
          req.set( 'origin', 'https://joukou.com' )
          req.set( 'access-control-request-method', 'POST' )
          req.set( 'access-control-request-headers', 'accept, authorization, content-type' )
        )
        .res( ( res ) ->
          res.should.have.status( 204 )
          res.should.have.header( 'access-control-allow-origin', 'https://joukou.com' )
          res.should.have.header( 'access-control-allow-credentials', 'true' )
          res.should.have.header( 'access-control-allow-methods', 'POST, OPTIONS' )
          res.should.have.header( 'access-control-allow-headers', 'accept, accept-version, content-type, request-id, origin, x-api-version, x-request-id, x-requested-with, authorization, accept, accept-version, content-type, request-id, origin, x-api-version, x-request-id' )
          done()
        )
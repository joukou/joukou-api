###*
Copyright 2014 Joukou Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

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
          res.should.have.header( 'access-control-allow-credentials', 'true' )
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
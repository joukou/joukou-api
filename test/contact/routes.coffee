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

assert        = require( 'assert' )
chai          = require( 'chai' )
should        = chai.should()
chai.use( require( 'chai-http' ) )

server        = require( '../../dist/server' )

xdescribe 'contact/routes', ->

  describe 'POST /contact', ->

    specify 'creates an email message based on a message-oriented contact request', ( done ) ->
      chai.request( server )
        .post( '/contact' )
        .req( ( req ) ->
          req.type( 'json' )
          req.send(
            name: 'Isaac Johnston'
            email: 'isaac.johnston@joukou.com'
            message: 'This is a test.'
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          done()
        )

    specify 'creates an email message based on a signup-oriented contact request', ( done ) ->
      chai.request( server )
        .post( '/contact' )
        .req( ( req ) ->
          req.type( 'json' )
          req.send(
            name: 'Isaac Johnston'
            email: 'isaac.johnston@joukou.com'
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          done()
        )
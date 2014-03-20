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
chai = require( 'chai' )
should = chai.should()
chai.use( require( 'chai-http' ) )

server = require( '../dist/server' )
riakpbc = require( '../dist/riak/pbc' )

log = ( v ) ->
  console.log(require('util').inspect(v, depth: 10))

describe 'GET /', ->

  specify 'responds 200 OK with a representation of the entry point', ( done ) ->
    chai.request( server )
      .get( '/' )
      .res( ( res ) ->
        res.should.have.status( 200 )
        res.body.should.deep.equal(
          _links:
            curies: [
              {
                name: 'joukou'
                templated: true
                href: 'https://rels.joukou.com/{rel}'
              }
            ]
            self:
              href: '/'
            'joukou:agent-authn': [
              {
                title: 'Authenticate'
                href: '/agent/authenticate'
              }
            ]
            'joukou:contact': [
              {
                title: 'Send a Message to Joukou'
                href: '/contact'
              }
            ]
            'joukou:agent-create': [
              {
                title: 'Create an Agent'
                href: '/agent'
              }
            ]
        )
        done()
      )

  xdescribe 'POST /agent', ->

    agentOneKey = null
    agentOneAuthorization = "Basic #{new Buffer( "test+one@joukou.com:password" ).toString( 'base64' )}"

    after ( done ) ->
      riakpbc.del(
        type: 'agent'
        bucket: 'agent'
        key: agentOneKey
      , ( err, reply ) -> done( err ) )

    specify 'responds 201 Created with a representation containing a link to the created agent in the given data is valid', ( done ) ->
      chai.request( server )
        .post( '/agent' )
        .req( ( req ) ->
          req.type( 'json' )
          req.send(
            email: 'test+one@joukou.com'
            password: 'password'
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          res.headers.location.should.match( /^\/agent\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/ )
          agentOneKey = res.headers.location.match( /^\/agent\/(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})$/ )[ 1 ]
          res.body.should.deep.equal(
            _links:
              curies: [
                {
                  name: 'joukou'
                  templated: true
                  href: 'https://rels.joukou.com/{rel}'
                }
              ]
              self:
                href: '/agent'
              'joukou:agent': [
                {
                  href: "/agent/#{agentOneKey}"
                }
              ]
          )
          done()
        )

    specify 'responds 403 Forbidden with a representation of the error if the given data in invalid', ( done ) ->
      chai.request( server )
        .post( '/agent' )
        .req( ( req ) ->
          req.type( 'json' )
        )
        .res( ( res ) ->
          res.should.have.status( 403 )
          done()
        )

    describe 'GET /agent/:agentKey', ->

      specify 'responds 200 OK with a representation of the agent if the agent key is valid', ( done ) ->
          chai.request( server )
            .get( "/agent/#{agentOneKey}" )
            .req( ( req ) ->
              req.set( 'Authorization', agentOneAuthorization )
            )
            .res( ( res ) ->
              res.should.have.status( 200 )
              res.body.should.deep.equal(
                email: 'test+one@joukou.com'
                _links:
                  curies: [
                    {
                      name: 'joukou',
                      templated: true,
                      href: 'https://rels.joukou.com/{rel}'
                    }
                  ]
                  self:
                    href: "/agent/#{agentOneKey}"
                  'joukou:personas': [
                    {
                      title: 'List of Personas'
                      href: '/persona'
                    }
                  ]
              )
              done()
            )

      specify 'responds 401 Unauthorized with a representation of the error if the agent key is invalid', ( done ) ->
          chai.request( server )
            .get( "/agent/c4b56b5e-0d47-4c8d-abd8-31f41c164b34" )
            .req( ( req ) ->
              req.set( 'Authorization', agentOneAuthorization )
            )
            .res( ( res ) ->
              res.should.have.status( 401 )
              done()
            )

    describe 'POST /agent/authenticate', ->

      specify 'responds 200 OK with a representation containing a JSON Web Token if the provided Authorization header is authenticated', ( done ) ->
        chai.request( server )
          .post( '/agent/authenticate' )
          .req( ( req ) ->
            req.set( 'Authorization', agentOneAuthorization )
          )
          .res( ( res ) ->
            res.should.have.status( 200 )
            should.exist( res.body.token )
            res.body.token.should.be.a( 'string' )
            res.body.should.deep.equal(
              token: res.body.token
              _links:
                curies: [
                  name: 'joukou'
                  templated: true
                  href: 'https://rels.joukou.com/{rel}'
                ]
                self:
                  href: '/agent/authenticate'
                'joukou:agent': [
                  {
                    href: "/agent/#{agentOneKey}"
                  }
                ]
                'joukou:personas': [
                  {
                    href: '/persona'
                    title: 'List of Personas'
                  }
                ]
            )
            done()
          )

      specify 'responds 401 Unauthorized if the provided Authorization header is not authenticated due to an incorrect password', ( done ) ->
        chai.request( server )
          .post( '/agent/authenticate' )
          .req( ( req ) ->
            req.set( 'Authorization', "Basic #{new Buffer( 'test+one@joukou.com:bogus' ).toString( 'base64' )}")
          )
          .res( ( res ) ->
            res.should.have.status( 401 )
            res.body.should.be.empty
            done()
          )

      specify 'responds 401 Unauthorized if the provided Authorization header is not authenticated due to an incorrect email', ( done ) ->
        chai.request( server )
          .post( '/agent/authenticate' )
          .req( ( req ) ->
            req.set( 'Authorization', "Basic #{new Buffer( 'test+bogus@joukou.com:password' ).toString( 'base64' )}")
          )
          .res( ( res ) ->
            res.should.have.status( 401 )
            res.body.should.be.empty
            done()
          )

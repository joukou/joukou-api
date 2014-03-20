"use strict"

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

async = require( 'async' )
server = require( '../../../../dist/server' )
riakpbc = require( '../../../../dist/riak/pbc' )

AgentModel = require( '../../../../dist/agent/Model' )
GraphModel = require( '../../../../dist/persona/graph/Model' )
PersonaModel = require( '../../../../dist/persona/Model' )

describe 'persona/graph/process/routes', ->

  agentKey = null
  personaKey = null
  graphKey = null

  before ( done ) ->
    AgentModel.create(
      email: 'test+persona+graph+process+routes@joukou.com'
      name: 'test/persona/graph/process/routes'
      password: 'password'
    ).then( ( agent ) ->
      agent.save()
    )
    .then( ( agent ) ->
      agentKey = agent.getKey()
      PersonaModel.create(
        name: 'test/persona/graph/process/routes'
        agents: [
          {
            key: agentKey
            role: 'creator'
          }
        ]
      )
    )
    .then( ( persona ) ->
      persona.save()
    )
    .then( ( persona ) ->
      personaKey = persona.getKey()
      GraphModel.create(
        name: 'test/persona/graph/process/routes'
        personas: [
          {
            key: personaKey
          }
        ]
      )
    )
    .then( ( graph ) ->
      graph.save()
    )
    .then( ( graph ) ->
      graphKey = graph.getKey()
      done()
    )
    .fail( ( err ) -> done( err ) )

  after ( done ) ->
    async.parallel([
      ( next ) ->
        riakpbc.del(
          type: 'agent'
          bucket: 'agent'
          key: agentKey
        , ( err, reply ) -> next( err ) )
      ( next ) ->
        riakpbc.del(
          type: 'persona'
          bucket: 'persona'
          key: personaKey
        , ( err, reply ) -> next( err ) )
      ( next ) ->
        riakpbc.del(
          type: 'graph'
          bucket: 'graph'
          key: graphKey
        , ( err, reply ) -> next( err ) )
    ], ( err ) -> done( err ) )

  describe 'POST /persona/:personaKey/graph/:graphKey/process', ->

    specify 'creates a process', ( done ) ->
      chai.request( server )
        .post( "/persona/#{personaKey}/graph/#{graphKey}/process" )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer('test+persona+graph+process+routes@joukou.com:password').toString('base64')}" )
          req.send(
            _links:
              'joukou:circle':
                href: "/persona/#{personaKey}/circle/a76439ea-61b3-4048-933c-5ace385634d0"
            metadata:
              x: 360
              y: 480
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          done()
        )

    xdescribe 'GET /persona/:personaKey/graph/:graphKey/process', ->

      specify 'responds with 200 OK and a representation of a list of processes', ( done ) ->
        chai.request( server )
          .get( "/persona/#{personaKey}/graph/#{graphKey}/process" )
          .req( ( req ) ->
            req.set( 'Authorization', "Basic #{new Buffer('test+persona+graph+process+routes@joukou.com:password').toString('base64')}" )
          )
          .res( ( res ) ->
            res.should.have.status( 200 )
            done()
          )

    describe 'GET /persona/:personaKey/graph/:graphKey/process/:processKey', ->

      specify 'responds with 404 NotFound if the process key parameter is invalid', ( done ) ->
        chai.request( server )
          .get( "/persona/#{personaKey}/graph/#{graphKey}/process/98519787-5caa-494c-9677-6290656cf11d" )
          .req( ( req ) ->
            req.set( 'Authorization', "Basic #{new Buffer('test+persona+graph+process+routes@joukou.com:password').toString('base64')}" )
          )
          .res( ( res ) ->
            res.should.have.status( 404 )
            done()
          )

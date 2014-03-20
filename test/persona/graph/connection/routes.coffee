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

describe 'persona/graph/connection/routes', ->

  agentKey = null
  personaKey = null

  before ( done ) ->
    AgentModel.create(
      email: 'test+persona+graph+connection+routes@joukou.com'
      name: 'test/persona/graph/connection/routes'
      password: 'password'
    ).then( ( agent ) ->
      agent.save()
    )
    .then( ( agent ) ->
      agentKey = agent.getKey()
      PersonaModel.create(
        name: 'test/persona/graph/connection/routes'
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
    ], ( err ) -> done( err ) )
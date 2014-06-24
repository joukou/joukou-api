"use strict"

###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
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
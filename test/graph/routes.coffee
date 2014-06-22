###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

assert        = require( 'assert' )
chai          = require( 'chai' )
should        = chai.should()
chai.use( require( 'chai-http' ) )

async         = require( 'async' )
server        = require( '../../dist/server' )
riakpbc       = require( '../../dist/riak/pbc' )
AgentModel    = require( '../../dist/agent/Model' )
GraphModel    = require( '../../dist/graph/Model' )
PersonaModel  = require( '../../dist/persona/Model' )

describe 'graph/routes', ->

  agentKey = null
  personaKey = null

  before ( done ) ->
    AgentModel.create(
      email: 'test+graph+routes@joukou.com'
      name: 'test/graph/routes'
      password: 'password'
    ).then( ( agent ) ->
      agent.save()
    )
    .then( ( agent ) ->
      agentKey = agent.getKey()
      PersonaModel.create(
        name: 'test/graph/routes'
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

  describe 'POST /persona/:personaKey/graph', ->

    specify 'creates a new graph', ( done ) ->
      chai.request( server )
        .post( "/persona/#{personaKey}/graph" )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer('test+graph+routes@joukou.com:password').toString('base64')}" )
          req.send(
            properties:
              name: 'Test Graph Routes'
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          res.headers.location.should.match( /^\/persona\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\/graph\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/ )
          graphKey = res.headers.location.match( /^\/persona\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\/graph\/(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})$/ )[ 1 ]
          chai.request( server )
            .get( res.headers.location )
            .req( ( req ) ->
              req.set( 'Authorization', "Basic #{new Buffer('test+graph+routes@joukou.com:password').toString('base64')}" )
            )
            .res( ( res ) ->
              res.should.have.status( 200 )

              riakpbc.del(
                type: 'graph'
                bucket: 'graph'
                key: graphKey
              , ( err, reply ) -> done( err ) )
            )
        )

  describe 'GET /graph/:graphKey', ->

    specify 'responds with 404 NotFound status code if the provided graph key is not valid', ( done ) ->
      chai.request( server )
        .get( '/graph/7ec23d7d-9522-478c-97a4-2f577335e023' )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer('test+graph+routes@joukou.com:password').toString('base64')}" )
        )
        .res( ( res ) ->
          res.should.have.status( 404 )
          res.body.should.be.empty
          done()
        )

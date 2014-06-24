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
GraphModel    = require( '../../dist/persona/graph/Model' )
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

    specify 'creates a graph', ( done ) ->
      chai.request( server )
        .post( "/persona/#{personaKey}/graph" )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer('test+graph+routes@joukou.com:password').toString('base64')}" )
          req.send(
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
              res.body.should.deep.equal(
                name: 'Test Graph Routes'
                _embedded:
                  'joukou:process': []
                  'joukou:connection': []
                _links:
                  'joukou:persona': [
                    {
                      href: "/persona/#{personaKey}"
                    }
                  ]
                  'joukou:process-create': [
                    {
                      title: 'Add a Process to this Graph'
                      href: "/persona/#{personaKey}/graph/#{graphKey}/process"
                    }
                  ]
                  'joukou:processes': [
                    {
                      title: 'List of Processes for this Graph'
                      href: "/persona/#{personaKey}/graph/#{graphKey}/process"
                    }
                  ]
                  'joukou:connection-create': [
                    {
                      title: 'Add a Connection to this Graph'
                      href: "/persona/#{personaKey}/graph/#{graphKey}/connection"
                    }
                  ]
                  'joukou:connections': [
                    {
                      title: 'List of Connections for this Graph'
                      href: "/persona/#{personaKey}/graph/#{graphKey}/connection"
                    }
                  ]
                  self:
                    href: "/persona/#{personaKey}/graph/#{graphKey}"
                  curies: [
                    {
                      name: 'joukou'
                      templated: true
                      href: 'https://rels.joukou.com/{rel}'
                    }
                  ]
              )
              riakpbc.del(
                type: 'graph'
                bucket: 'graph'
                key: graphKey
              , ( err, reply ) -> done( err ) )
            )
        )

  describe 'GET /persona/:personaKey/graph/:graphKey', ->

    specify 'responds with 404 NotFound status code if the provided graph key is not valid', ( done ) ->
      chai.request( server )
        .get( '/persona/e78cd405-8dce-472d-82bb-88c9862a58d1/graph/7ec23d7d-9522-478c-97a4-2f577335e023' )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer('test+graph+routes@joukou.com:password').toString('base64')}" )
        )
        .res( ( res ) ->
          res.should.have.status( 404 )
          res.body.should.be.empty
          done()
        )

  describe 'POST /persona/:personaKey/graph/:graphKey/process', ->

    graphKey = null

    before ( done ) ->
      GraphModel.create(
        properties:
          name: 'Add Process Test'
        personas: [
          {
            key: personaKey
          }
        ]
      )
      .then( ( graph ) ->
        graph.save()
      )
      .then( ( graph ) ->
        graphKey = graph.getKey()
        done()
      )
      .fail( ( err ) -> done( err ) )

    specify 'adds a process to a graph', ( done ) ->
      chai.request( server )
        .post( "/persona/#{personaKey}/graph/#{graphKey}/process" )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer('test+graph+routes@joukou.com:password').toString('base64')}" )
          req.send(
            _links:
              'joukou:circle':
                href: "/persona/#{personaKey}/circle/7eee9052-5a7e-410d-9cb7-6e099c489001"
            metadata:
              x: 100
              y: 100
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          res.headers.location.should.match( /^\/persona\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\/graph\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\/process\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/ )
          processKey = res.headers.location.match( /^\/persona\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\/graph\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\/process\/(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})$/ )[ 1 ]
          res.body.should.deep.equal(
            _links:
              self:
                href: "/persona/#{personaKey}/graph/#{graphKey}/process"
              curies: [
                {
                  name: 'joukou'
                  templated: true
                  href: 'https://rels.joukou.com/{rel}'
                }
              ]
              'joukou:process': [
                href: "/persona/#{personaKey}/graph/#{graphKey}/process/#{processKey}"
              ]          
          )
          chai.request( server )
            .get( res.headers.location )
            .req( ( req ) ->
              req.set( 'Authorization', "Basic #{new Buffer('test+graph+routes@joukou.com:password').toString('base64')}" )
            )
            .res( ( res ) ->
              res.should.have.status( 200 )
              res.body.should.deep.equal(
                metadata:
                  x: 100
                  y: 100
                _links:
                  self:
                    href: "/persona/#{personaKey}/graph/#{graphKey}/process/#{processKey}"
                  curies: [
                    {
                      name: 'joukou'
                      templated: true
                      href: 'https://rels.joukou.com/{rel}'
                    }
                  ]
                  'joukou:circle': [
                    {
                      href: "/persona/#{personaKey}/circle/7eee9052-5a7e-410d-9cb7-6e099c489001"
                    }
                  ]          
              )
              done()
            )
        )
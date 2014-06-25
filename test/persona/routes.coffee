###*
@author Isaac Johnston <isaac.johnston@joukou.com>
@copyright (c) 2009-2014 Joukou Ltd. All rights reserved.
###

assert        = require( 'assert' )
chai          = require( 'chai' )
should        = chai.should()
chai.use( require( 'chai-http' ) )

AgentModel    = require( '../../dist/agent/Model' )
PersonaModel  = require( '../../dist/persona/Model' )
server        = require( '../../dist/server' )
riakpbc       = require( '../../dist/riak/pbc' )

describe 'persona/routes', ->

  agentKey = null

  before ( done ) ->
    AgentModel.create(
      email: 'test+persona+routes@joukou.com'
      name: 'test/persona/routes'
      password: 'password'
    ).then( ( agent ) ->
      agent.save()
    )
    .then( ( agent ) ->
      agentKey = agent.getKey()
      done()
    )
    .fail( ( err ) -> done( err ) )

  after ( done ) ->
    riakpbc.del(
      type: 'agent'
      bucket: 'agent'
      key: agentKey
    , ( err, reply ) -> done( err ) )

  describe 'POST /persona', ->

    specify 'creates a new persona given valid data', ( done ) ->
      chai.request( server )
        .post( '/persona' )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer( "test+persona+routes@joukou.com:password" ).toString( 'base64' )}" )
          req.send(
            name: 'Joukou Ltd'
          )
        )
        .res( ( res ) ->
          res.should.have.status( 201 )
          res.headers.location.should.match( /^\/persona\/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/ )
          personaKey = res.headers.location.match( /^\/persona\/(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})$/ )[ 1 ]
          chai.request( server )
            .get( res.headers.location )
            .req( ( req ) ->
              req.set( 'Authorization', "Basic #{new Buffer( "test+persona+routes@joukou.com:password" ).toString( 'base64' )}" )
            )
            .res( ( res ) ->
              res.should.have.status( 200 )
              res.body.should.deep.equal(
                name: 'Joukou Ltd'
                _links:
                  curies: [
                    {
                      name: 'joukou'
                      templated: true
                      href: 'https://rels.joukou.com/{rel}'
                    }
                  ]
                  self:
                    href: "/persona/#{personaKey}"
                  'joukou:agent': [
                    {
                      name: 'creator'
                      href: "/agent/#{agentKey}"
                    }
                  ]
                  'joukou:graphs': [
                    {
                      title: 'List of Graphs owned by this Persona'
                      href: "/persona/#{personaKey}/graph"
                    }
                  ]
                  'joukou:graph-create': [
                    {
                      title: 'Create a Graph owned by this Persona'
                      href: "/persona/#{personaKey}/graph"
                    }
                  ]
                  'joukou:circles': [
                    {
                      title: 'List of Circles available to this Persona'
                      href: "/persona/#{personaKey}/circle"
                    }
                  ]
              )
              riakpbc.del(
                type: 'persona'
                bucket: 'persona'
                key: personaKey
              , ( err, reply ) -> done( err ) )
            )
        )

  describe 'GET /persona/:personaKey', ->

    specify 'responds with 404 NotFound status code if the provided persona key is not valid', ( done ) ->
      chai.request( server )
        .get( '/persona/7ec23d7d-9522-478c-97a4-2f577335e023' )
        .req( ( req ) ->
          req.set( 'Authorization', "Basic #{new Buffer( "test+persona+routes@joukou.com:password" ).toString( 'base64' )}" )      
        )
        .res( ( res ) ->
          res.should.have.status( 404 )
          done() 
        )



